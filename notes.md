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

Major Concerns
---

* Discussion about call discipline
    * Silent pass-through in modifier - is it guaranteed to return false
    * incoming abort/error EIP
    * modifier return values EIPS
* token abstractions can negate fee - despite not being in scope of review, must suggest to fix to demurrage model

Minor Concerns / Suggestions
---

* compiler version (and associated fixes e.g. import paths)
* Use constructors for "permanent init" functions
* "proxy" term
* When "call safety comments" are necessary - explicit is fine, but only reentry check necessary for typed calls
