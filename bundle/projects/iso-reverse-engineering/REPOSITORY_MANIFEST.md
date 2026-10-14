# REA ISO/firmware reverse-engineering source manifest

Updated: 2026-10-14

This file records official upstream repositories pinned to exact commit IDs. These entries are Git submodules (gitlinks), not copies of all source files in this repository. A normal Git checkout does not materialize their working trees automatically. From the repository root, initialize them with:

```bash
git submodule update --init --recursive
```

Large sources such as ReactOS, Wine, Winbindex, EDK II, and libguestfs can require substantial disk space. The list pins the commit IDs found at the upstream default branch at import time; commits remain reproducible unless an upstream deletes the referenced object.

The separate `edk2-platforms` source is intentionally imported as a source snapshot by the one-time GitHub Actions workflow, because its entry is materialized in this bundle rather than left as a gitlink.

## Requested project paths

| Path | Upstream | Branch checked | Pinned commit | Handling |
|---|---|---|---|---|
| `capa` | [`mandiant/capa`](https://github.com/mandiant/capa) | `master` | `9cf793abf84f23ef9887b6fd7e6a9f6838b55708` | Git submodule |
| `capa-rules` | [`mandiant/capa-rules`](https://github.com/mandiant/capa-rules) | `master` | `805f9eaccfb6a4e1ddffc809d71d1e2b5ccc15e5` | Git submodule |
| `chipsec` | [`chipsec/chipsec`](https://github.com/chipsec/chipsec) | `chipsec2` | `c11756375417cc859e25a98e0788849ebd6eb8cc` | Git submodule |
| `cutter` | [`rizinorg/cutter`](https://github.com/rizinorg/cutter) | `dev` | `d7f11b220884a6cc8549da955b744bd318645103` | Git submodule |
| `detect-it-easy` | [`horsicq/Detect-It-Easy`](https://github.com/horsicq/Detect-It-Easy) | `master` | `dd9ac5fa6762bdc28a96097e6d81aecf9571afda` | Git submodule |
| `dissect` | [`fox-it/dissect`](https://github.com/fox-it/dissect) | `main` | `8477b4f4aaeb9070011dbd99cde81c990dd4d779` | Git submodule |
| `dynamorio` | [`DynamoRIO/dynamorio`](https://github.com/DynamoRIO/dynamorio) | `master` | `d1a47572c0ad60cc9f6e5eb240a6028e4c4a5693` | Git submodule |
| `edk2` | [`tianocore/edk2`](https://github.com/tianocore/edk2) | `master` | `0d61209231b2ec50ca6f6b96825baaa07c280854` | Git submodule |
| `flare-floss` | [`mandiant/flare-floss`](https://github.com/mandiant/flare-floss) | `master` | `f03936da325561cde7652a153f31923da0aa8990` | Git submodule |
| `flare-vm` | [`mandiant/flare-vm`](https://github.com/mandiant/flare-vm) | `main` | `5dc321d336f2d1b0c77343bdfd8cd3ac01ba1b37` | Git submodule |
| `frida` | [`frida/frida`](https://github.com/frida/frida) | `main` | `3c7ea1530edb0c3bb9b1de84444510163052b18a` | Git submodule |
| `imhex` | [`WerWolv/ImHex`](https://github.com/WerWolv/ImHex) | `master` | `34483cb90527cd71c92049ef3b1b2cc27936a1d4` | Git submodule |
| `libguestfs` | [`libguestfs/libguestfs`](https://github.com/libguestfs/libguestfs) | `master` | `af937d2f0f76ef599e212e5214cb9f6dc3f5c1f6` | Git submodule |
| `lief` | [`lief-project/LIEF`](https://github.com/lief-project/LIEF) | `main` | `5416ff2e2fcda29924c2f868a7249b4318359c41` | Git submodule |
| `pe-bear` | [`hasherezade/pe-bear`](https://github.com/hasherezade/pe-bear) | `main` | `b90f1d7d96635e7a029f424a0d1d11a104821685` | Git submodule |
| `pe-parse` | [`trailofbits/pe-parse`](https://github.com/trailofbits/pe-parse) | `master` | `9e4e3587969ea2410dadda1ccfa909aec1121d09` | Git submodule |
| `pe-tree` | [`blackberry/pe_tree`](https://github.com/blackberry/pe_tree) | `master` | `2be607fc55702293cd02cbc6cda5283452464aff` | Archived mirror |
| `pefile` | [`erocarrera/pefile`](https://github.com/erocarrera/pefile) | `master` | `58186a92164842cf758822e067bc79c59b3c80d9` | Git submodule |
| `phnt` | [`winsiderss/phnt`](https://github.com/winsiderss/phnt) | `master` | `53fbbdc5b5d2b08761db1c7b26bfa8c820924356` | Git submodule |
| `qiling` | [`qilingframework/qiling`](https://github.com/qilingframework/qiling) | `master` | `86c927cb329993b14e2586e04d1dd7a90deee5fb` | Git submodule |
| `reactos` | [`reactos/reactos`](https://github.com/reactos/reactos) | `master` | `c63ed8b88c2876f87aa7f227b4ac22c0556c174b` | Git submodule |
| `snowman` | [`yegord/snowman`](https://github.com/yegord/snowman) | `master` | `8c26cb1979822f7afe9504c72c9f022e2418fd6e` | Git submodule |
| `speakeasy` | [`mandiant/speakeasy`](https://github.com/mandiant/speakeasy) | `master` | `aa9f22643f4519e0555141cd16ee25eb971b5518` | Git submodule |
| `syft` | [`anchore/syft`](https://github.com/anchore/syft) | `main` | `ddc490c5c5606048715f4668e8adcc4a6267df3d` | Git submodule |
| `volatility3` | [`volatilityfoundation/volatility3`](https://github.com/volatilityfoundation/volatility3) | `develop` | `77ff0b1932d77527f850c8ced01d85805ea7bf97` | Git submodule |
| `winbindex` | [`m417z/winbindex`](https://github.com/m417z/winbindex) | `main` | `aacec0c2e1c622127dc72123f60c9c986fc94a2f` | Git submodule |
| `windows-driver-samples` | [`microsoft/Windows-driver-samples`](https://github.com/microsoft/Windows-driver-samples) | `main` | `2dc3fd3a0cc84a2933f2194e7ec0871584979071` | Git submodule |
| `wine` | [`wine-mirror/wine`](https://github.com/wine-mirror/wine) | `master` | `5b6b85421c2a2161728b2a55e9f09271770a3eb0` | Git submodule |
| `x64dbg` | [`x64dbg/x64dbg`](https://github.com/x64dbg/x64dbg) | `development` | `4fc92664f0ea63136c07c68ea848a994ea2749c6` | Git submodule |
| `ghidra` | [`NationalSecurityAgency/ghidra`](https://github.com/NationalSecurityAgency/ghidra) | `master` | `918acd744d17e3b95fbde44ec6ab3e59b6dbd45f` | Git submodule |
| `ilspy` | [`icsharpcode/ILSpy`](https://github.com/icsharpcode/ILSpy) | `master` | `dad8a25ed2b742c64b7e22b5db6cc13c69f3e9b2` | Git submodule |
| `radare2` | [`radareorg/radare2`](https://github.com/radareorg/radare2) | `master` | `0ad346ff016627d686a2af51156adfc96ccde6d2` | Git submodule |
| `rizin` | [`rizinorg/rizin`](https://github.com/rizinorg/rizin) | `dev` | `0164b933e43789a5cd16a2d7fb967c1f619502e1` | Git submodule |

## Submodules declared inside imported source trees

These two dependencies were declared by source-tree `.gitmodules` files but were not materialized by the earlier flattened imports. Their paths are now registered in the superproject `.gitmodules` and represented by gitlinks.

| Path | Upstream | Branch checked | Pinned commit |
|---|---|---|---|
| `bundle/projects/iso-reverse-engineering/kaitai-struct-formats/.github/push_artifacts` | [`kaitai-io/push_artifacts`](https://github.com/kaitai-io/push_artifacts) | `master` | `04b0a00a4dae1858f027ab0e96b8971e282cd48b` |
| `bundle/projects/iso-reverse-engineering/msitools/subprojects/bats-core` | [`bats-core/bats-core`](https://github.com/bats-core/bats-core) | `master` | `0c92eb4c418d59fcb1a1a8c1d7a015f8149689f2` |

## Notes

- `pe-tree` is pinned to the archived `blackberry/pe_tree` public mirror; the original `hasherezade/pe_tree` endpoint could not be resolved while auditing.
- `pe-parse` is pinned to `trailofbits/pe-parse`.
- The four projects previously stored elsewhere in `bundle/projects` (Ghidra, ILSpy, radare2, and Rizin) are also referenced under this ISO/firmware path so the expected directory inventory is consistent. Their earlier copies were not deleted.
- Git submodule links do not replace the license notices of the upstream projects. Review each license before redistribution.
