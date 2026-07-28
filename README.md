<!-- jr-brand:start -->
<div align="center">
  <a href="https://jannikreinhard.com/">
    <img src="https://raw.githubusercontent.com/JayRHa/.github/main/assets/readme/brand-header.png" alt="Jannik Reinhard — Driving AI with passion" width="100%">
  </a>
  <h1>Intune App Creator</h1>
  <p><strong>PowerShell tool for automated creation, packaging, and deployment preparation of Intune Win32 apps.</strong></p>
  <p>
  <a href="https://jannikreinhard.com/"><img src="https://img.shields.io/badge/Website-146CDD?style=flat-square&amp;logo=wordpress&amp;logoColor=white" alt="Website"></a>
  <a href="https://github.com/JayRHa"><img src="https://img.shields.io/badge/GitHub-081427?style=flat-square&amp;logo=github&amp;logoColor=white" alt="GitHub"></a>
  <a href="https://www.linkedin.com/in/jannik-r/"><img src="https://img.shields.io/badge/LinkedIn-0795FF?style=flat-square&amp;logo=linkedin&amp;logoColor=white" alt="LinkedIn"></a>
  <a href="https://x.com/jannik_reinhard"><img src="https://img.shields.io/badge/X-081427?style=flat-square&amp;logo=x&amp;logoColor=white" alt="X"></a>
  <a href="https://www.youtube.com/@jannikreinhard"><img src="https://img.shields.io/badge/YouTube-146CDD?style=flat-square&amp;logo=youtube&amp;logoColor=white" alt="YouTube"></a>
  </p>
  <p><sub>Driving AI with passion · Microsoft Foundry · Intune · Azure</sub></p>
</div>
<!-- jr-brand:end -->

## Overview

Packaging a Windows application for Microsoft Intune takes several repetitive steps. I built Intune App Creator to search the Chocolatey catalog, package an application and prepare it for Intune from one workflow.

[Read the original introduction on my blog](https://jannikreinhard.com/2022/08/01/introduction-of-the-chocolatey-intune-app-creator/).

![Intune App Creator start page](assets/startpage.png)

## Quickstart

```powershell
git clone https://github.com/JayRHa/IntuneAppCreator.git
cd IntuneAppCreator
Get-ChildItem -Recurse *.dll | Unblock-File
.\Start-IntuneAppCreator.ps1
```

Run the tool on Windows with PowerShell. Review every generated package and test the application with a limited Intune assignment before production deployment.

## Repository Structure

| Path | Purpose |
| --- | --- |
| `Start-IntuneAppCreator.ps1` | Starts the application |
| `modules/` | Packaging, UI and utility functions |
| `xaml/` | WPF interface definitions |
| `libaries/` | Required WPF libraries |

## License

This project is available under the terms in [LICENSE](LICENSE).

<!-- jr-brand-footer:start -->

---

<div align="center">
  <p><sub>Built and maintained by <a href="https://jannikreinhard.com/">Jannik Reinhard</a> · Microsoft MVP for Security and AI Platform.</sub></p>
  <p><a href="https://www.buymeacoffee.com/jannikreinf">Support the open-source work</a></p>
  <p><strong>Stay healthy, Cheers Jannik</strong></p>
</div>

<!-- jr-brand-footer:end -->
