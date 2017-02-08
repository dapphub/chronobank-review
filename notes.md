Disclaimer
---

* our best attempt to review
* no system is safe until proper verification tools exist - compiler errors are still common

Scope
---

* certain files
* no verification of any deployed bytecode
* no incentive verification

Methodology
---

Commit 29f89620085c7292474ea52f166fe912722e43a5 ("audit-head") was cloned and turned into a line-by-line review document, generating one page per Solidity file.

Simple Suggestions
---

* compiler version (and associated fixes e.g. import paths)

Major Concerns
---

* Discussion about call discipline
    * Silent pass-through in modifier - is it guaranteed to return false
    * incoming abort/error EIP
    * modifier return values EIPS
* token abstractions can negate fee - despite not being in scope of review, must suggest to fix to demurrage model

Minor Concerns / Suggestions

* Use constructors for "permanent init" functions
* "proxy" term

