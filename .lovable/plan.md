

## Fix: Store full option text instead of "Option A/B" in manually created campaigns

**Change:** In `src/pages/AddCampaign.tsx`, line 512, replace:

```js
const optionValue = `Option ${option}`;
```

with:

```js
const optionValue = getOptionText(question, option);
```

This ensures `value_json.selected_values` stores the human-readable text (e.g., `"Under $500k"`) instead of `"Option A"`, matching the format used by the WhatsApp bot. One-line change, high confidence fix.

