           Bitpusher
            \`._,'/
            (_- -_)
              \o/
          The Digital
              Fox
          @VinceVulpes
    https://theTechRelay.com
 https://github.com/bitpusher2k

# ScriptTemplates

## Basic Batch (BAT) and PowerShell (PS1) scripting templates

## By Bitpusher/The Digital Fox

## v1.8 last updated 2024-02-27

 A set of basic templates for BAT/PS scripts to facilitate good practices
 when scripting for scheduled tasks and automation across many endpoints.
 When running scripts in a way that the execution is not being monitored
 there are several factors which become much more important:

 1. Documentation - Standardized information and instructions at 
      the beginning of the script (name, version, date, how to).
 2. Logging - Central log location & basic log management. Including of
      endpoint name in log name. Option to email log file or copy to 
      shared folder. Uses PS transcript for accuracy and verbosity of log.
 3. Date stamps - Date stamps included in log name and in the log files
      themselves, including ISO8601-formatted version.
 4. Process priority - Includes option to set script priority 
      (for scripts that are resource intensive).
 5. Timing of execution - Includes option to add random delay to script
      execution (for staggering execution when running across many endpoints).
 6. Error handling - Catches basic errors, and set up to return exit status.
 
"TEMPLATE_with_Transcript.ps1" is the main and preferred template for the purpose, with "TEMPLATE_simple.ps1" to be used when a transcript of execution is not wanted or does not work (happens sometimes), and "TEMPLATE.bat" to be used whe PowerShell is not an option.

Now expanded with template for interactive scripts, PS remoting files, and drag-and-drop BAT to PS shim.

Incorporates some features from https://eitanblumin.com/2021/06/08/one-handy-powershell-script-template-to-rule-them-all/ https://github.com/MadeiraData/MadeiraToolbox/blob/master/Utility%20Scripts/Powershell_Template_with_Transcript.ps1
