Cross references
========================

See also: http://www.uniprot.org/manual/?query=category%3Across_references

## Parameters:

(* = required)

| Name                 | Description                          |
|----------------------|--------------------------------------|
| *data-stanza-tax-id  | Taxonomy identifier. (e.g., 1111708) |
| *data-stanza-gene-id | Gene identifier. (e.g., sll0018)     |

## Sample:

```html
<div data-stanza="http://togogenome.org/stanza/protein_cross_references" data-stanza-tax-id="1111708" data-stanza-gene-id="sll0018"></div>
```

The above `<div>` will automatically embed the following Stanza in your HTML page.

<div data-stanza="http://togogenome.org/stanza/protein_cross_references" data-stanza-tax-id="1111708" data-stanza-gene-id="sll0018"></div>

Test:
<div data-stanza="/protein_cross_references" data-stanza-tax-id="1111708" data-stanza-gene-id="sll0018"></div>
