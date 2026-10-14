# REA ecosystem source bundle

Research snapshot: 2026-10-12. This bundle groups the original REA project, distinct AI-agent/MCP alternatives, and major source-level reverse-engineering engines. It is a curated, broad search—not a guarantee that every repository on GitHub has been found. Repositories are shallow-cloned from their default branches; submodules are requested recursively where available. Nothing is compiled or executed.

## Original project
- [morluto/rea](https://github.com/morluto/rea) — unified MCP/CLI agent workflows for native binaries, applications, JavaScript/Electron, .NET and runtime investigation. MIT.
  - Its `third_party` submodules already include `1013503897/jadx-headless-mcp`, `ReFirmLabs/binwalk`, `onekey-sec/unblob`, `Washi1337/ghidra-nativeaot`, and `pionxzh/wakaru`; those are included within `original/rea/third_party` rather than duplicated as separate top-level copies.

## Agent platforms, MCP bridges and AI-assisted analysis
- [LING71671/open-reverselab](https://github.com/LING71671/open-reverselab) — multi-tool AI reverse-engineering lab and MCP server covering Ghidra, Frida, x64dbg, Rizin, APK/PE/binary workflows and an executable knowledge base. GPL-3.0.
- [ReverserID/JURIG](https://github.com/ReverserID/JURIG) — autonomous, Android-first reverse-engineering agent with native-binary tooling. **GitHub did not report a declared license at research time; check with the author before redistribution or reuse.**
- [lkimuk/ReArk](https://github.com/lkimuk/ReArk) — desktop AI-assisted inspection of Android/HarmonyOS packages and native PE/ELF/Mach-O binaries. Apache-2.0.
- [Sarks0/binary-mcp](https://github.com/Sarks0/binary-mcp) — MCP integrations for Ghidra, x64dbg, WinDbg and ILSpyCmd. Apache-2.0.
- [xjoker/delamain](https://github.com/xjoker/delamain) — headless JADX MCP for APK/DEX/AAB investigation. Apache-2.0.
- [asLody/dexdec](https://github.com/asLody/dexdec) — Android bytecode decompilation workbench with agent/MCP integration. Apache-2.0.
- [android-security-engineer/ApkToolSkills](https://github.com/android-security-engineer/ApkToolSkills) — AI-oriented APK analysis CLI and skills with structured JSON output. Apache-2.0; fork of Apktool.
- [android-security-engineer/dex2jar-skills](https://github.com/android-security-engineer/dex2jar-skills) — AI-oriented DEX/JAR analysis workflows and MCP integration. Apache-2.0; fork of dex2jar.
- [LaurieWired/GhidraMCP](https://github.com/LaurieWired/GhidraMCP) — MCP bridge for Ghidra. Apache-2.0.
- [mrexodia/ida-pro-mcp](https://github.com/mrexodia/ida-pro-mcp) — AI/MCP bridge for IDA Pro; requires a separately licensed IDA Pro installation. MIT.
- [cyberkaida/reverse-engineering-assistant](https://github.com/cyberkaida/reverse-engineering-assistant) — Ghidra-focused reverse-engineering MCP server. Apache-2.0.
- [jtsylve/re-mcp](https://github.com/jtsylve/re-mcp) — headless MCP bridge for IDA Pro and Ghidra. Apache-2.0.

## Major source-level engines and specialist analyzers
- [NationalSecurityAgency/ghidra](https://github.com/NationalSecurityAgency/ghidra) — broad software reverse-engineering framework and decompiler. Apache-2.0; individual bundled components may have their own notices.
- [radareorg/radare2](https://github.com/radareorg/radare2) — portable, scriptable reverse-engineering and analysis toolkit. GitHub API returned no single SPDX license; preserve and read repository license notices.
- [rizinorg/rizin](https://github.com/rizinorg/rizin) — radare2-derived reverse-engineering framework. LGPL-3.0.
- [skylot/jadx](https://github.com/skylot/jadx) — Android DEX/APK decompiler. Apache-2.0.
- [iBotPeaches/Apktool](https://github.com/iBotPeaches/Apktool) — Android package decode/build tooling. Apache-2.0.
- [pxb1988/dex2jar](https://github.com/pxb1988/dex2jar) — DEX/JAR conversion and analysis tooling.
- [androguard/androguard](https://github.com/androguard/androguard) — Android app reverse engineering and programmatic analysis. Apache-2.0.
- [MobSF/Mobile-Security-Framework-MobSF](https://github.com/MobSF/Mobile-Security-Framework-MobSF) — automated mobile-app static/dynamic analysis and security assessment. GPL-3.0.
- [icsharpcode/ILSpy](https://github.com/icsharpcode/ILSpy) — cross-platform .NET decompiler. MIT.
- [frida/frida-core](https://github.com/frida/frida-core) and [frida/frida-tools](https://github.com/frida/frida-tools) — dynamic instrumentation core and CLI tooling; check their repository/component notices for licensing.
- [angr/angr](https://github.com/angr/angr) — program analysis, symbolic execution and binary reasoning. BSD-2-Clause.
- [avast/retdec](https://github.com/avast/retdec) — retargetable machine-code decompiler. MIT.

## Important scope and safety notes
- This bundle contains source repositories, not prebuilt environments, paid tools, app samples or a ready-to-run reverse-engineering workstation.
- Tools may require platform-specific runtimes, Android SDKs, emulators/devices, Ghidra, IDA Pro, drivers or additional dependencies.
- Licensing varies by project and by bundled component. License statements above reflect repository metadata reviewed for this snapshot; preserve each source tree's LICENSE/NOTICE files and check them before reuse or redistribution.
- Forks that merely copy REA (including sgunin/ReverseEngineerAnything, teonett/Reverse-Engineer-Anything and illumi-ai/REA) are not duplicated as separate projects; the original is present once.
