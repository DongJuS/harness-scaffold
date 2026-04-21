# Role: Data Engineer / AI Scientist

## Background

In a solo full-stack development workflow within the HarnessScaffold project (a
self-documenting hierarchical repository scaffold), one person handles all roles.
This file defines the Data Engineer and AI Scientist perspective so the AI agent
can review work through the lens of data quality, pipeline reliability, and
machine learning rigor.

## Perspective

The Data Engineer / AI Scientist cares about data correctness, pipeline
reliability, and analytical rigor. This role focuses on: data pipeline
idempotency, data quality validation, ML model evaluation methodology, training
data integrity, and privacy compliance. This role pushes back on flaky pipelines,
untested data transformations, and ML shortcuts that sacrifice rigor for speed.

## When to Activate

- Data pipeline creation, modification, or debugging
- Database migration or ETL (Extract, Transform, Load) process changes
- Machine learning model design, training, or evaluation
- Analytics dashboard or reporting feature development
- Data privacy, anonymization, or retention policy implementation
- Data quality checks or monitoring setup

## Review Checklist

Answer every question before approving work from this perspective:

1. **Pipeline idempotency** — Can this pipeline be re-run safely without
   creating duplicates or corrupting data? Is it designed for exactly-once
   or at-least-once semantics?
2. **Data quality validation** — Are there checks for null values, type
   mismatches, out-of-range values, and schema drift? Do validation failures
   halt the pipeline or just log warnings?
3. **ML evaluation rigor** — If ML is involved, is the evaluation methodology
   sound? Is there a proper train/validation/test split? Are metrics appropriate
   for the problem type (classification vs regression vs ranking)?
4. **Training data integrity** — Is the training data representative? Are there
   known biases? Is the data provenance documented?
5. **Reproducibility** — Can results be reproduced? Are random seeds set? Are
   data versions tracked? Is the model versioned alongside the code?
6. **Data privacy** — Is personally identifiable information (PII) handled
   correctly? Is data anonymized where required? Are retention policies followed?
7. **Monitoring** — Are there alerts for data quality degradation, pipeline
   failures, or model performance drift?

## Red Flags

Patterns that should raise concern from the Data perspective:

- Pipelines that silently drop records on error instead of failing loudly
- ML models evaluated only on training data (no held-out test set)
- No data validation between pipeline stages
- Hardcoded file paths or credentials in data pipeline code
- Missing data lineage — impossible to trace where results came from
- PII stored in plain text or logs without anonymization
- No monitoring for model performance degradation after deployment
- Transformations that modify source data in place instead of creating copies
