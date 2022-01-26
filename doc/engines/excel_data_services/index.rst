ExcelDataServices
##################

ExcelDataServices encompasses all services that convert excel files (input)
into structured data, that gets saved in our database (output).

Models
======

ExcelDataServices::Upload
--------------------------

Upload provides a wrapper on top of any information that is useful in the context of an upload pipeline.
Most importantly it keeps track of the async job and its status as well as the attached file.

:id:
  Primary key

:organization_id:
  Foreign key to Organizations::Organization.

:user_id:
  Foreign key to Users::User.

:file_id:
  Foreign key to Legacy::File.

:status:
  Keeps track of the current status of any given upload.
  Enum, any of ["not_started", "superseded", "processing", "failed", "done"].

:last_job_id:
  Sidekiq job id.

:created_at:
  Timestamp.

:updated_at:
  Timestamp.

  .. toctree::
    :hidden:

    cell_parser/index.rst
    column/index.rst
    matrix/index.rst
    conflicts/index.rst
    dynamic_columns/index.rst
    dynamic_fees/index.rst
    extractors/index.rst
    formatters/index.rst
    model_initializer/index.rst
    operations/index.rst
    overlaps/index.rst
    row_validation/index.rst
    schemas/index.rst
    section/index.rst
    sheet_type/index.rst
    upload/index.rst
    workflow/index.rst