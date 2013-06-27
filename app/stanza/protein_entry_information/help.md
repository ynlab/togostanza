Entry information
=========================

See also: http://www.uniprot.org/manual/?query=category%3Aentry_information

## Parameters:

(* = required)

| Name                 | Description                          |
|----------------------|--------------------------------------|
| *data-stanza-tax-id  | Taxonomy identifier. (e.g., 1111708) |
| *data-stanza-gene-id | Gene identifier. (e.g., slr1311)     |

## Sample:

```html
<div data-stanza="http://togogenome.org/stanza/protein_entry_information" data-stanza-tax-id="1111708" data-stanza-gene-id="slr1311"></div>
```

The above `<div>` will automatically embed the following Stanza in your HTML page.

<div data-stanza="http://togogenome.org/stanza/protein_entry_information" data-stanza-tax-id="1111708" data-stanza-gene-id="slr1311"></div>

Test:
<div data-stanza="/protein_entry_information" data-stanza-tax-id="1111708" data-stanza-gene-id="slr1311"></div>
