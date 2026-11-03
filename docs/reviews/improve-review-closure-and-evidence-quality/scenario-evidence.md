# Scenario Evidence: Review Closure and Evidence Quality

Change: `improve-review-closure-and-evidence-quality`

Original implementation batch: `engrelay-review-closure-evidence-20261103-01`

## Correction and limits

The original implementation report claimed five observed Agent judgments, but its
surviving JSON and assertion log did not establish input-to-Agent-return correspondence.
The original scenario 2 summary also reproduced two prohibited fictional values while
claiming zero remaining occurrences. The subsequent [pre-release review](2026-11-03-pre-release-review.md)
records these findings. The earlier review, its verdict and rating remain historical facts.
This corrected summary replaces those unsupported observation claims with the actual
bounded exercise below; it does not imply the earlier evidence was sufficient.

The exercises use invented tasks and prior results. They are maintenance observations,
not independent verdicts for the fictional tasks, actual package installation, host
loading, fresh Lite-session isolation, universal host adherence or token-saving proof.
The same Agent session read Full rules before reading Lite rules; Lite results therefore
do not establish isolation from previously read Full context. The raw fictional inputs,
exact invocation messages, Agent returns and redacted deliverable remain in the ignored
local `.ai/review-closure-evidence/correction-trial/` directory for authorized inspection.

## Candidate rule fingerprints

| Candidate file | SHA256 |
| --- | --- |
| `payload/docs/ai-collaboration/README.md` | `D2CFAB91EEA047F4B31033BEFA4DF6A3F24624C3670A5C8FA2948F58A37CA831` |
| `payload/docs/ai-collaboration/lite/RULES.md` | `1677BF962B4550251F8BAAB7AE1ADA1F3B82C3C4EF06ADC02B88024E60225C2C` |
| `payload/docs/ai-collaboration/agent-prompts.md` | `5E096E2F686A456D68D8060F8AADDB124712B1F7524A24B4F40C5658EDED390F` |
| `payload/docs/ai-collaboration/workflows.md` | `BAA276C1C4C30376D081B75F403ED6A51A6BB4C7181C4968F3AA0FDEF4F84371` |
| `payload/docs/ai-collaboration/templates/review-round.template.md` | `D737EFB69601E3FC6909E40376D7A7E3741BAB2609FFA517E9EA5E0C9798F9AA` |
| `payload/docs/ai-collaboration/lite/templates/task.md` | `12B3378A7DB66DD32BF5493F571AA1A5593FA499930C62A35B9176F378B1E8B3` |

The evaluator was instructed to read the Full README for scenarios 1 and 3 and
Lite RULES for scenarios 2, 4 and 5. The other fingerprints identify the broader
candidate rules associated with this change; the exercise does not claim they
were all read or executed by the evaluator. SHA256 identifies bytes, not authorship.

## Actual invocation and returns

Evaluator: `/root/fix_review_evidence/scenario_evaluator`, an actual delegated
Agent created with `fork_turns=none`, then resumed once for scenarios 2–5.
It returned scenario 1 before receiving the other scenario inputs. The invoking
Fix Engineer copied its final returns into the named local evidence files without
editing the returned text. The local records contain the exact delegation messages,
inputs and observations; the model's undisclosed reasoning and internal host state
are not claimed.

| Local evidence under `correction-trial/` | SHA256 |
| --- | --- |
| `scenario-01-input.md` | `FE42F211215EE44B343C3D5D8ACE4942EFE149DBE37BED66D49FB3AC51195AB2` |
| `scenario-01-response.md` | `E01133001440C8BF2734938F31BFAA12450096925F550B45302DD06D3C36B550` |
| `scenarios-02-05-input.md` | `B12639426E265E7D82C7905C290C30C8095026CCC7F210EDEF37103B8DF3B408` |
| `scenario-02-private-input.md` | `A0F54FAE4CF8A5E3F9321A74EE63BB22005A62BBA4006339D11BA8173D5FBEAD` |
| `scenarios-02-05-response.md` | `BDE71E167628D2224E0963F108145530B9E13F4DA4641B904ABCC73611F03355` |
| `scenario-02-redacted-delivery.md` | `C4DB72EEC6D4E89C1F97D5C10689C8386AA525BD2644179D4DE2F4A52D286EBA` |
| `agent-provenance-response.md` | `24F0A5B78C91996B949C7EC57A028DDECBF2B116F9F494769DDF0CB398B9FDBD` |

The invocation records are `scenario-01-invocation.md` and
`scenarios-02-05-invocation.md`. The scenario 2 input was extracted from the
fictional report text only; the original JSON also contained prewritten judgments,
which were not supplied to the evaluator. No source value is reproduced here.
The evaluator later reported its actual rule-read and artifact-write steps in
`agent-provenance-response.md`: one Full section extractor and the first artifact
patch attempt had errors, followed by reported successful reads and a successful
artifact write/readback. Its account is available, while its raw tool transcript
was not provided to the invoking session.

## Observed decisions

1. **Wrong evidence, Full:** The supplied prior upload result exercised a different
   entrypoint from the required retrieval. The Agent returned `unverified`, identified
   the missing retrieval and checksum evidence, and recommended correcting the claim
   without making an unauthorized external call.
2. **Local redaction, Lite:** The Agent wrote and reread an actual fictional delivery
   artifact using placeholders. It treated the supplied, unchanged-input 12/12 result
   as applicable while expressly saying it had not rerun or independently verified it;
   it called for checking privacy and preserved meaning without unrelated suite reruns.
   The correction check inspects the actual deliverable, Agent return and both workspace
   and staged copies of this summary for two distinct prohibited fictional markers; it
   reports counts only. The original restricted fixture remains ignored.
3. **Changed shared contract, Full:** The Agent kept the finding open because a helper
   test did not cover callers expecting the old return type. It identified middleware
   and session handling as affected and called for corresponding repair or checks and
   independent verification.
4. **Finite extension and later review, Lite:** For a fictional grant from 3 through 4,
   the Agent limited the scoped review to that ceiling and did not authorize another
   autonomous cycle on failure. For the closed task, it preserved closure and count,
   linked the requested privacy review and required applicable authorization for a
   genuinely new repair.
5. **Archive scope, Lite:** Given the stated clean current checks, the Agent ended the
   current archive check and reported the unrelated historical validation failure
   separately. It did not claim that the unrelated global check passed.

The exact fictional inputs and Agent returns, rather than these summaries alone,
are the evidence for the observations. Follow-up checks, exits and their limitations
are recorded in `.ai/review-closure-evidence/correction-result.md`.
