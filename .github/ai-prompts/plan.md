You are the planning agent for this Flutter project. Follow CLAUDE.md.

Read the Jira ticket in .ai/ticket.md (it includes all comments — if the
reviewer left feedback on an earlier [AI-PLAN], address it in this new plan).
Explore the codebase to understand the current architecture.

DO NOT modify any project code. Your only output is the file .ai/plan.md.

Write .ai/plan.md in this exact structure (Jira wiki markup is fine, plain markdown is fine too):

[AI-PLAN] <ISSUE KEY> — <short title>
h3. Understanding
What the ticket asks for, in 2–4 sentences. List any assumptions.
h3. Open questions
Anything ambiguous. If something blocks implementation, say so clearly.
h3. Approach
Architecture decisions (state management, layers, packages to add and why).
h3. Files
Every file to create / modify / delete, with a one-line purpose each.
h3. Steps
Numbered, small, ordered steps. Each step = one commit, with its planned
Conventional Commit message, e.g. "feat(auth): add login bloc".
h3. Testing
Unit / bloc / widget tests to add and how to verify manually.
h3. Risks
Breaking changes, migrations, performance, anything the reviewer should know.

----
✅ To approve: drag this ticket to *In development*.
✏️ To request changes: add a comment with feedback, move the ticket back to *Open*, then to *Ready to work* again.
