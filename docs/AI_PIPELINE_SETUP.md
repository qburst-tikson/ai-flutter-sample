# Jira → Claude → GitHub: automated Flutter pipeline

## The flow

Uses your existing board columns (project **SCRUM** on qburst-ai-sample-flutter.atlassian.net),
so no new Jira statuses are needed. Only tickets with the label **`ai`** go through the AI.

```
 Open ──drag──▶ Ready to work ──▶ GitHub Action: ai-plan.yml
                                    │  Claude reads ticket + codebase
                                    │  writes plan (read-only, nothing pushed)
                                    ▼
                    Plan posted as Jira comment [AI-PLAN]
                                    │
          ┌──────── YOU review the plan in Jira ────────┐
          │                                             │
  Not happy: comment feedback,              Happy: drag to "In development"
  drag back to Open, then to                            │
  Ready to work (Claude re-plans)                       ▼
                                          GitHub Action: ai-implement.yml
                                            │ branch feature/SCRUM-2-slug
                                            │ Claude implements step by step,
                                            │ one Conventional Commit per step
                                            │ format + analyze + test
                                            ▼
                         push → Pull Request → Jira comment with PR link
                         Ticket → "In review"   (you review, merge, move to Close)
```

Nothing reaches your base branch without a human merging the PR.

---

## 1. Add files to your Flutter repo

Copy into the repo root:

```
.github/workflows/ai-plan.yml
.github/workflows/ai-implement.yml
scripts/jira.sh
CLAUDE.md            ← edit to match your project's real conventions
```

Commit them to your **default branch** (repository_dispatch only runs workflows that exist on the default branch).

## 2. Jira board mapping

| Column | Meaning in the pipeline | Who moves it |
|---|---|---|
| Open | backlog | you |
| Ready to work | **triggers planning** | you |
| In development | **plan approved, triggers implementation** | you |
| In review | PR is open | the bot |
| Close | merged | you |

Add the label **`ai`** to any ticket you want the AI to handle. Tickets without it are ignored, so normal dragging by your team won't start the AI.

If you rename the "In review" column, set the repo variable `JIRA_REVIEW_STATUS` to the new name.

## 3. Credentials

**Jira API token:** https://id.atlassian.com/manage-profile/security/api-tokens
Use a dedicated bot account if possible, so comments show as "AI Bot".

**Claude auth (pick one):**
- `ANTHROPIC_API_KEY` from console.anthropic.com (pay-as-you-go), or
- `CLAUDE_CODE_OAUTH_TOKEN`: run `claude setup-token` locally if you're on a Claude Pro/Max plan. Then in both YAML files swap the commented line.

**GitHub PAT (recommended):** fine-grained token on this repo with
*Contents: Read & write*, *Pull requests: Read & write*.
Two uses:
1. Jira Automation uses it to trigger the workflows.
2. As `GH_PAT`, so PRs opened by the bot trigger your normal CI (PRs opened with the default `GITHUB_TOKEN` don't).

## 4. GitHub repo settings

**Settings → Secrets and variables → Actions → Secrets:**

| Secret | Value |
|---|---|
| `ANTHROPIC_API_KEY` | your key (or `CLAUDE_CODE_OAUTH_TOKEN`) |
| `JIRA_BASE_URL` | `https://qburst-ai-sample-flutter.atlassian.net` |
| `JIRA_EMAIL` | email of the Jira account owning the token |
| `JIRA_API_TOKEN` | the Jira API token |
| `GH_PAT` | the GitHub PAT (optional but recommended) |

**Variables tab:** `AI_BASE_BRANCH`: optional, defaults to `main`.

**Settings → Actions → General → Workflow permissions:** "Read and write permissions" and tick "Allow GitHub Actions to create and approve pull requests".

## 5. Jira Automation rules (2 rules)

**Project settings → Automation → Create rule.**

### Rule A: Plan
- **Trigger:** Work item transitioned → *to status* `Ready to work`
- **Condition:** Work item fields condition → `Labels` *contains any of* `ai`
- **Action:** Send web request
  - URL: `https://api.github.com/repos/qburst-tikson/ai-flutter-sample/dispatches`
  - Method: `POST`
  - Headers:
    - `Accept: application/vnd.github+json`
    - `Authorization: Bearer <GITHUB_PAT>` (tick "hidden")
    - `X-GitHub-Api-Version: 2022-11-28`
  - Body (custom data):
    ```json
    { "event_type": "jira-plan", "client_payload": { "issue_key": "{{issue.key}}" } }
    ```

### Rule B: Implement
Same as Rule A, except:
- **Trigger:** Work item transitioned → *to status* `In development`
- **Condition:** same `Labels` contains `ai`
- **Body:** `"event_type": "jira-implement"`

Note: Jira's free plan has a monthly limit on automation rule runs. That's plenty for testing, but check the usage page under Automation if you scale up.

## 6. Test it

1. Manual first: **Actions → AI Plan (Jira) → Run workflow** → enter a real key like `SCRUM-2`. Check that the plan comment appears in Jira.
2. Then **AI Implement (Jira) → Run workflow** with the same key. Check the PR.
3. Then try the full loop from Jira by moving the ticket.

## Writing tickets that work well

Claude is only as good as the ticket. Include:
- What screen / feature, with acceptance criteria as a bullet list
- API endpoint + sample request/response JSON if networking is involved
- Design: Figma link or a short description of the layout
- Out of scope: what NOT to touch

## Safety notes
- The plan job has read-only repo access and never pushes.
- The implement job can't push, reset or rebase; only the workflow pushes, and only to `feature/<KEY>-*`.
- Protect your base branch (Settings → Branches → require PR review). Then even a bad run can only produce a PR.
- If checks fail, the PR opens as **draft** and the Jira comment says so.
- Set a monthly spend limit on your Anthropic console key.

## Troubleshooting
| Symptom | Fix |
|---|---|
| Jira rule fires, nothing in Actions | Workflows not on default branch, or PAT lacks Contents: write |
| `No [AI-PLAN] comment found` | Run the plan phase first; plan comment must start with `[AI-PLAN]` |
| 401 from Jira | Wrong `JIRA_EMAIL`/token pair, or base URL has a trailing path |
| Transition warnings in log | Status names in Jira differ; rename in YAML or Jira |
| PR doesn't trigger CI | Add `GH_PAT` secret |
| Claude stops mid-way | Raise `--max-turns`, or split the ticket into smaller ones |
