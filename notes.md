Disclaimer
---

* our best attempt to review
* no system is safe until proper verification tools exist - compiler errors are still common
* make note of "scope" section

Scope
---

* only certain files
* no verification of compiled bytecode
* no incentive analysis

Major Concerns
---

* Discussion about call discipline
    * Silent pass-through in modifier - depends on poorly specified compiler semantics - is it guaranteed to return false?
    * incoming abort/error EIP
    * modifier return values EIPS
* token abstractions can negate fee - despite not being in scope of review, must suggest to fix to demurrage model
* no reference to crowdsale logic

"Rent token" model
---

While incentive analysis was out of scope of this review, we feel compelled to offer a general suggestion related to any token monetization model:

We assume in the current model that one "LHT" is a claim on some kind of tangible service. It is

The current model for monetizing LHT for the benefit of TIME holders on-chain appears to be a per-unit fee that is charged on `transfer`.

Regardless of what LHT tokens actually represent, this fee is easily circumvented in practice with a simple wrapper token:

```
todo
```

Suggest switching to demurrage+service model, where a token represents a decaying claim on the ability to use some "service" contract. This is a rent-seeking model that is resilient to any accounting tricks in the contract layer.


