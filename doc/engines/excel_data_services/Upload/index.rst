ExcelDataServices::V2::Upload
=============================

Provided with a file, the Upload class will loop through the available
SheetType schemas and detect if any of them are valid for the file.

If a match is found that SheetType class will perform its insertion
task, returning a list of Stats objects holding the success/ failure
messages.

The Upload class will combine these Stats into the format expected by
the UploadMailer.

