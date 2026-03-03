

## Add "Source" indicator to Campaign Overview

**Change:** In `src/pages/CampaignDetail.tsx`, add a new grid item in the Campaign Overview section (after the existing fields around line 1164) that shows whether the campaign was manually created or automatically created via WhatsApp/Calendly.

**Logic:** Check if `campaign.twilio_conversation_sid` is null/empty — if so, it's "Manually Created"; otherwise, "Auto (WhatsApp)".

**UI:** A small labeled field matching the existing pattern:
```
<h4 className="font-medium text-sm text-muted-foreground">Source</h4>
<Badge variant="outline">Manually Created</Badge>
// or
<Badge variant="info">WhatsApp Bot</Badge>
```

Single file change, ~10 lines added.

