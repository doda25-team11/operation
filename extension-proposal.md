# Extension Proposal: Release-Impact Contribution Guardrails

## Shortcoming (Release Engineering)
The current contribution process allows changes to be merged without verifying release-impact requirements such as **changelog updates, versioning implications, or explicit release notes**. This is a release-engineering shortcoming because it pushes release-critical decisions to **late stages** (e.g., the release pipeline or manual maintainer review), increasing the risk of inconsistent releases.

### Why this is critical, annoying, and error-prone
- **Changelog drift:** Features and fixes can be merged without being documented, leading to incomplete or inaccurate release notes.
- **Versioning errors:** Without explicit signals in PRs, maintainers can easily miss when a change should trigger a version bump or require migration notes.
- **Late discovery:** Release managers discover missing documentation or compatibility notes only at release time, causing delays or rushed fixes.
- **Inconsistent discipline:** The quality of release information varies depending on who reviews or merges the PR.

This shortcoming is directly tied to the **contribution process** assignment category and affects downstream release pipelines.

---

## Proposed Extension (Non-trivial, implementable in 1–5 days)
Introduce **contribution guardrails for release impact** by combining:
1. **PR template additions** requiring explicit release-impact declaration (e.g., "no impact", "patch", "minor", "major", "breaking").
2. **CI checks** that validate:
   - A changelog entry exists for non-trivial changes.
   - A “release-impact” label is present when required.
   - Release-impact selection matches repository versioning policy (e.g., semantic versioning rules).
3. **Automated changelog enforcement** (e.g., a standardized changelog fragment or structured entry in `CHANGELOG.md`).

### Concrete tasks (implementation plan)
1. **Define release-impact labels** (e.g., `release-impact:patch`, `release-impact:minor`, `release-impact:major`, `release-impact:none`).
2. **Add a PR template** that requires contributors to:
   - Choose a release-impact category.
   - Indicate whether a changelog entry is required.
3. **Add CI validation step** in the release/contribution pipeline:
   - Parse PR metadata for release-impact label.
   - Check for changelog entry if impact ≠ none.
   - Fail the check if requirements are missing.
4. **Document the policy** in `CONTRIBUTING.md` and link it from the PR template.
5. **Optional (stretch):** enforce via a GitHub Action or workflow that blocks merge if checks fail.

---

## Expected Outcome
- **Higher release quality:** Every merged change includes structured release information.
- **Faster release prep:** Maintainers do not need to retroactively build release notes or infer impact.
- **Reduced human error:** CI enforcement prevents missing documentation or misclassified changes.
- **More consistent versioning decisions** across contributors.

This is general and reusable: similar guardrails apply to any project using release pipelines or semantic versioning.

---

## How to Test the Improvement (Experiment Design)
**Goal:** Determine if the guardrails reduce release errors and improve release documentation quality.

### Proposed experiment
- **Baseline:** Measure last 3 releases before implementing the extension:
  - % of merged PRs lacking changelog entries but included in release.
  - Number of release delays due to missing notes or versioning confusion.
- **After implementation:** Measure the next 3 releases using the same metrics.

### Metrics
1. **Changelog completeness rate**  
   `(PRs merged with non-trivial changes and changelog entry) / (PRs merged with non-trivial changes)`
2. **Release preparation time**  
   Time spent by maintainers compiling release notes.
3. **Release errors**  
   Count of release corrections caused by missing/incorrect notes.

**Expected result:** Higher changelog completeness, reduced release prep time, and fewer release corrections.

---

## Assumptions and Downsides
- **Assumption:** Contributors will follow the template and CI checks will be easy to adopt.
- **Downside:** Additional contributor friction (more steps in PRs).
- **Risk:** CI checks could be overly strict if labeling or changelog rules are unclear.
- **Mitigation:** Provide clear examples and allow `release-impact:none` for trivial changes.

---

## References
- [Semantic Versioning 2.0.0](https://semver.org/)  
- [GitHub Docs: About issue and pull request templates](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/about-issue-and-pull-request-templates)  
- [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)  
- [GitHub Actions: Workflow syntax for GitHub Actions](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)  

---

## Summary
This extension addresses a critical release-engineering gap by enforcing release-impact declarations and changelog discipline at contribution time. It is feasible within 1–5 days and produces a measurable improvement in release quality and reliability.