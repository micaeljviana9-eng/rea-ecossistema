# ReArk

English | [简体中文](README.zh-CN.md)

ReArk is a desktop reverse engineering and AI-assisted analysis tool for HarmonyOS NEXT, Android, and iOS applications. Open HarmonyOS `.hap`, `.app`, and `.abc` files, Android `.apk` and `.aab` packages, or iOS `.ipa` files to inspect code, resources, metadata, signatures, and application behavior in one workspace. Standalone Windows PE, ELF, and Mach-O binaries can also be opened directly for native analysis.

Combine static analysis with connected-device inspection and ReArk Agent to investigate application logic, review security, and work through CTF challenges.

## Installation and platforms

Download the installer for your computer from [Latest release](https://github.com/lkimuk/ReArk/releases/latest). See [All releases](https://github.com/lkimuk/ReArk/releases) for version history and release notes.

| OS | Requirements | Direct links |
| :---: | --- | --- |
| <img src="https://raw.githubusercontent.com/devicons/devicon/v2.17.0/icons/windows8/windows8-original.svg" width="44" height="44" alt="Windows"><br>Windows | Windows 10+<br>x64 | [![Setup x64](https://img.shields.io/badge/Setup-x64-0078D4?style=flat-square)](https://github.com/lkimuk/ReArk/releases/download/v1.0.0/ReArk-1.0.0-windows-x64-setup.exe) |
| <img src="https://raw.githubusercontent.com/devicons/devicon/v2.17.0/icons/apple/apple-original.svg" width="44" height="44" alt="macOS"><br>macOS | macOS 14.0+<br>Apple Silicon | [![DMG Apple Silicon](https://img.shields.io/badge/DMG-Apple_Silicon-000000?style=flat-square&logo=apple&logoColor=white)](https://github.com/lkimuk/ReArk/releases/download/v1.0.0/ReArk-1.0.0-macos-arm64.dmg) |
| <img src="https://raw.githubusercontent.com/devicons/devicon/v2.17.0/icons/linux/linux-original.svg" width="44" height="44" alt="Linux"><br>Linux | x64<br>System requirements to be announced | Coming in the next release |

## Feature Highlights

**Package and static analysis**

- Supports HarmonyOS NEXT `.hap`, `.app`, and `.abc`, Android `.apk` and `.aab`, and iOS `.ipa` files
- Browse package structure, modules, generated source output, resources, signatures, and metadata
- Disassemble and decompile ABC bytecode; explore strings, literals, cross-references, and call argument flows
- Inspect Android manifests, permissions, components, entry points, resources, and application icons
- Read Android disassembly and Java-like decompiled output
- Inspect iOS IPA signatures and certificate chains
- View hex data, formatted JSON, XML, text, images, and media resources; search files and navigate source output

**Native binary analysis**

- Open Windows PE (`.exe`, `.dll`), ELF, and Mach-O executables and libraries directly
- Browse headers, sections, imports, exports, relocations, and dependencies
- Review security mitigations such as ASLR, DEP/NX, PIE, RELRO, stack canaries, and CFG
- Navigate structure-aware listings and hex views with field-level annotations

**HarmonyOS signing and packaging**

- Inspect signatures, certificates, and signing validity
- Configure signing materials, re-sign, and repackage HarmonyOS applications
- Install supported application packages on connected devices; Android device installation uses APK files

**ReArk Agent**

- Ask contextual questions about the current HarmonyOS or Android package
- Discover analysis capabilities and retrieve package files, metadata, strings, disassembly, and decompiled output as needed
- Attach reference documents to supplement package evidence with your own materials
- Use supported model providers, including OpenAI-compatible endpoints and local Ollama models
- Combine static analysis with device workflows; host commands, Python execution, and device operations use the applicable approval flows

**Connected devices**

- Discover HarmonyOS devices through HDC and Android devices through ADB
- Install and launch applications, capture screenshots, inspect UI nodes, and read device logs
- Mirror device screens in real time and control devices using mouse and keyboard
- Use screen recording, audio, clipboard, and device controls where supported by the device and runtime
- Work with fullscreen or detached mirroring windows

Available analysis views and device actions depend on the package format, operating system version, and device capabilities. ABC evidence tools and HarmonyOS re-signing are specific to HarmonyOS packages.

## Screenshots

| Welcome and supported formats | Android package summary |
| --- | --- |
| <a href="assets/screenshots/welcome.png"><img src="assets/screenshots/welcome.png" alt="Welcome and supported formats" width="420"></a> | <a href="assets/screenshots/android-summary.png"><img src="assets/screenshots/android-summary.png" alt="Android package summary" width="420"></a> |

| iOS IPA summary | iOS signature chain |
| --- | --- |
| <a href="assets/screenshots/ios-summary.png"><img src="assets/screenshots/ios-summary.png" alt="iOS IPA summary" width="420"></a> | <a href="assets/screenshots/ios-signature.png"><img src="assets/screenshots/ios-signature.png" alt="iOS signature chain" width="420"></a> |

| PE analysis | ELF analysis |
| --- | --- |
| <a href="assets/screenshots/pe-summary.png"><img src="assets/screenshots/pe-summary.png" alt="PE analysis" width="420"></a> | <a href="assets/screenshots/elf-summary.png"><img src="assets/screenshots/elf-summary.png" alt="ELF analysis" width="420"></a> |

| HarmonyOS decompilation | Android decompilation |
| --- | --- |
| <a href="assets/screenshots/harmony-decompilation.png"><img src="assets/screenshots/harmony-decompilation.png" alt="HarmonyOS decompilation" width="420"></a> | <a href="assets/screenshots/android-decompilation.png"><img src="assets/screenshots/android-decompilation.png" alt="Android decompilation" width="420"></a> |

| ABC / Hex inspection | ABC strings |
| --- | --- |
| <a href="assets/screenshots/abc-hex.png"><img src="assets/screenshots/abc-hex.png" alt="ABC / Hex inspection" width="420"></a> | <a href="assets/screenshots/abc-strings.png"><img src="assets/screenshots/abc-strings.png" alt="ABC strings" width="420"></a> |

| ReArk Agent analysis | Android screen mirroring |
| --- | --- |
| <a href="assets/screenshots/agent-analysis.png"><img src="assets/screenshots/agent-analysis.png" alt="ReArk Agent analysis" width="420"></a> | <a href="assets/screenshots/android-mirroring.png"><img src="assets/screenshots/android-mirroring.png" alt="Android screen mirroring" width="420"></a> |

| PE annotated listing | PE structured hex view |
| --- | --- |
| <a href="assets/screenshots/pe-reark-view.png"><img src="assets/screenshots/pe-reark-view.png" alt="PE annotated listing" width="420"></a> | <a href="assets/screenshots/pe-hex-view.png"><img src="assets/screenshots/pe-hex-view.png" alt="PE structured hex view" width="420"></a> |

## Safety and Privacy

Use ReArk only for legally authorized reverse engineering, interoperability research, malware analysis, and security research.

When using ReArk Agent with remote model providers, avoid submitting secrets, certificates, user data, trade secrets, or other sensitive content.

## License

ReArk is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.

Third-party notices are listed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Support

- Issues: [GitHub Issues](https://github.com/lkimuk/ReArk/issues)
- User guide: [cppmore.com/ReArk](https://www.cppmore.com/category/ReArk/)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=lkimuk/ReArk&type=Date)](https://star-history.com/#lkimuk/ReArk&Date)
