#
# diffoscope: in-depth comparison of files, archives, and directories
#
# Copyright © 2024, 2026 Chris Lamb <lamby@debian.org>
# Copyright © 2022 Christopher Baines <mail@cbaines.net>
#
# diffoscope is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# diffoscope is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with diffoscope.  If not, see <https://www.gnu.org/licenses/>.

import os
import stat
import pathlib
import logging
import subprocess

from diffoscope.difference import Difference
from diffoscope.tools import tool_required
from diffoscope.tempfiles import get_temporary_directory

from .directory import Directory
from .symlink import Symlink

from .utils.file import File
from .utils.archive import Archive, ArchiveMember

logger = logging.getLogger(__name__)

# The top-level node of a NAR is unnamed, so use this when referring to it in
# file listings.
NAR_ROOT = "."

# "guix archive --extract" would be the obvious way to unpack a NAR, but it
# insists on connecting to guix-daemon, so use "guix repl" to call the
# underlying (guix serialization) code directly instead.
RESTORE_NAR_SCRIPT = str(
    pathlib.Path(__file__).parent.parent.joinpath("scripts", "restore-nar.scm")
)


class NarMember(ArchiveMember):
    @property
    def path(self):
        # We unpack the archive in one go, so point at the already-extracted
        # file rather than letting ArchiveMember create a temporary directory
        # per-member.
        return self.container.get_member_path(self._name)


class NarDirectory(Directory, NarMember):
    def __init__(self, container, member_name):
        NarMember.__init__(self, container, member_name)

    def compare(self, other, source=None):
        return None

    def has_same_content_as(self, other):
        return False

    def is_directory(self):
        return True

    def get_member_names(self):
        raise ValueError("archives are compared as a whole.")  # noqa

    def get_member(self, member_name):
        raise ValueError("archives are compared as a whole.")  # noqa


class NarSymlink(Symlink, NarMember):
    def __init__(self, container, member_name, destination):
        NarMember.__init__(self, container, member_name)
        self._destination = destination

    @property
    def symlink_destination(self):
        return self._destination

    def is_symlink(self):
        return True


class NarContainer(Archive):
    def open_archive(self):
        return True

    def close_archive(self):
        pass

    def get_member_names(self):
        self.ensure_unpacked()

        if not self._root_is_directory:
            return [self._root_member_name]

        return list(self.walk())

    def get_member(self, member_name):
        path = self.get_member_path(member_name)

        if os.path.islink(path):
            return NarSymlink(self, member_name, os.readlink(path))

        if os.path.isdir(path):
            return NarDirectory(self, member_name)

        return NarMember(self, member_name)

    def get_member_path(self, member_name):
        self.ensure_unpacked()

        if not self._root_is_directory:
            if member_name != self._root_member_name:
                raise KeyError(member_name)
            return self._root

        path = os.path.join(self._root, member_name)
        if not os.path.lexists(path):
            raise KeyError(member_name)

        return path

    def extract(self, member_name, dest_dir):
        # Ignore dest_dir; the archive is already unpacked in one go.
        return self.get_member_path(member_name)

    def walk(self, relative_to=""):
        """
        Yield the name of every node underneath the top-level directory,
        relative to it and in the order NAR stores them (ie. sorted), with
        directories appearing before their contents.
        """

        directory = os.path.join(self._root, relative_to)

        for name in sorted(os.listdir(directory)):
            member_name = os.path.join(relative_to, name)
            yield member_name

            path = os.path.join(self._root, member_name)
            if not os.path.islink(path) and os.path.isdir(path):
                yield from self.walk(member_name)

    def listing(self):
        """
        Describe the archive in terms of what NAR actually records: the type of
        each node, whether regular files are executable and where symlinks
        point.
        """

        self.ensure_unpacked()

        def describe(name, path):
            mode = os.lstat(path).st_mode

            if stat.S_ISLNK(mode):
                return f"symlink     {name} -> {os.readlink(path)}\n"
            if stat.S_ISDIR(mode):
                return f"directory   {name}\n"
            if mode & stat.S_IXUSR:
                return f"executable  {name}\n"

            return f"regular     {name}\n"

        yield describe(NAR_ROOT, self._root)

        if self._root_is_directory:
            for member_name in self.walk():
                yield describe(
                    member_name, os.path.join(self._root, member_name)
                )

    def compare(self, other, **kwargs):
        differences = []

        # Always include the file list; without it, added, removed or
        # newly-executable files would only show up as a binary diff.
        if other.source:
            differences.append(
                Difference.from_text_readers(
                    self.listing(),
                    other.listing(),
                    self.source.path,
                    other.source.path,
                    source="file list",
                )
            )

        differences.extend(super().compare(other, **kwargs))

        return differences

    @tool_required("guix")
    def ensure_unpacked(self):
        if hasattr(self, "_root"):
            return

        self._temp_dir_object = get_temporary_directory(suffix="nar")
        root = os.path.join(self._temp_dir_object.name, "contents")

        logger.debug("Extracting %s to %s", self.source.path, root)

        with open(self.source.path, "rb") as f:
            subprocess.run(
                ("guix", "repl", "--", RESTORE_NAR_SCRIPT, root),
                stdin=f,
                # The script is tiny, so byte-compiling it would cost more than
                # it saves (and would need a writable cache directory).
                env=dict(os.environ, GUILE_AUTO_COMPILE="0"),
                capture_output=True,
                check=True,
            )

        self._root = root
        self._root_is_directory = not os.path.islink(root) and os.path.isdir(
            root
        )

        if self._root_is_directory:
            # NAR restores directories read-only, which would prevent us from
            # removing the unpacked files again later.
            for dirpath, _, _ in os.walk(root):
                os.chmod(dirpath, os.lstat(dirpath).st_mode | stat.S_IWUSR)
        else:
            # A NAR containing a single file or symlink does not record a name
            # for it, so fall back to naming it after the archive itself.
            self._root_member_name = self.get_compressed_content_name(".nar")


class NarFile(File):
    DESCRIPTION = "nar files"
    CONTAINER_CLASSES = [NarContainer]

    FALLBACK_FILE_TYPE_HEADER_PREFIX = (
        len("nix-archive-1").to_bytes(8, byteorder="little") + b"nix-arch"
    )
