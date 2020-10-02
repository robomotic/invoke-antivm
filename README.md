Invoke-AntiVM v1.0
===============

Introduction
------------
Invoke-AntiVM is a set of modules to perform VM detection and fingerprinting (with exfiltration) via Powershell.

Compatibility
-------------
Run the script check-compatibility.ps1 to check what modules or functions are compatibile with the powershell version.
Our goal is to achieve compatibility from 2.0 but we are not there yet.
Please run check-compability.ps1 to see what are the current compatiblity issues.

Background
----------
We wrote this tool to unify several techniques to identify VM or sandbox technologies.
It relies on both signature and behavioural signals to identify whether a host is a VM or not.
The modules are categorized into logical groups: CPU, Execution,Network,Programs.
The user can also decide to exfiltrate a fingerprint of the target host to be able to determine what features can be used to identify a sandbox or VM solution.

Purpose
-------
Invoke-AntiVM exists was developed to understand what is the implication of using obfuscation and anti-vm tricks in powershell payloads.
We hope this will help Red Teams to avoid analysis of their payload and Blue Teams to understand how to debofuscate a script with evasion techniques.
You could either use the main module file Invoke-AntiVM.psd1 or use the singular ps1 script files if you want to reduce the size.



Usage
-----
Usage examples are provided in the following scripts:

* detect.ps1: this shows an example script of how to call the different tests
* usage.ps1: this shows basic usage
* usage_more.ps1: this shows more advanced functions
* usage_exfil.ps1: this shows how to exfiltrate host information as a json document via pastebin, web or email
* usage_fingerprint_file.ps1: this shows the exfiltration module and what data is generated in the form of a json document
* poc_fingerprint_combined.ps1: this shows the fingerprinting module used against online sandboxes
* output/poc.docm: this shows an example MS Word attack with a macro to call the fingerprinting module (uploaded previously to a server)


The folder pastebin contains a python script:

* full_fingerprints.py that download all the pastes
* decode_pastebins.ps1 to decompress and decode the fingerprint documents

You have to make sure you use the same encryption key you used during the exfiltration step.
The folder package shows how can you package all the scripts into a singular file for better portability.
The folder pastebin shows how to pull automatically and decode the exfiltrated documents from pastebin.


Installation
------------
The source code for Invoke-CradleCrafter is hosted at Github, and you may
download, fork and review it from this repository
(https://github.com/robomotic/invoke-antivm). Please report issues
or feature requests through Github's bug tracker associated with this project.

To install: run the script install_module.ps1

License
-------
Invoke-AntiVM is released under the Apache 2.0 license.

Release Notes
-------------

1.0
