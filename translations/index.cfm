﻿<cfinclude template="../plugin/config.cfm" />
<cfset exportTranslation=createObject("component","plugins.#pluginConfig.getDirectory()#.cfcs.exportTranslation")>

<cfif structKeyExists(form,"doaction")>
	<cfif form.doaction eq "export">
		
		<cfif not isDate(form.export_date)>
			<cfset form.export_date = createDate(1900,1,1) />
		</cfif>
		
		<cfset exportKey = exportTranslation.createExport($,form.export_date,form.template,pluginConfig) />
		
		<cfif len(exportKey)>
			<cfset form.export_action="download" />
		</cfif>
	<cfelseif form.doaction eq "doimport">
		<cfif fileExists( expandPath("/#pluginConfig.getDirectory()#/temp/report.txt") )>
			<cffile action="read" file="#expandPath("/#pluginConfig.getDirectory()#/temp/report.txt")#" variable="report" >
		</cfif>

		<cfset importKey = rereplace(createUUID(),"-","","all") />
		<cfset importDirectory = expandPath("/#pluginConfig.getDirectory()#/temp/#importKey#") />
		<cfset report = "" />

		<cfif not directoryExists(importDirectory)>
			<cfset directoryCreate(importDirectory)>
		</cfif>
		
		<cffile action="upload" filefield="import_file" destination="#importDirectory#" >

		<cfset responseMessage = exportTranslation.importTranslation($,form.template,file.serverDirectory,file.serverFile,pluginConfig) />

		<cfif responseMessage neq "true">
			<cfset form.export_action="importfailed" />
		<cfelse>
			<cfset form.export_action="importcomplete" />
		</cfif>
		
		<cfif fileExists( expandPath("/#pluginConfig.getDirectory()#/temp/report.txt") )>
			<cffile action="read" file="#expandPath("/#pluginConfig.getDirectory()#/temp/report.txt")#" variable="report" >
		</cfif>
	</cfif>
</cfif>


<cfparam name="panel" default="#StructNew()#" />
<cfparam name="panel.page" default="home" />

<cfif structKeyExists(form,"export_action")>
	<cfset panel.page = form.export_action />
</cfif>

<cfsavecontent variable="body">
<cfoutput>
<div class="mura-header">
	<h1>#pluginConfig.getName()#</h1>
	</div> <!-- /.mura-header -->

	<div class="block block-constrain">
			<div class="block block-bordered">
				<div class="block-content">

				<cfswitch expression="#panel.page#">
					<cfcase value="export">
						<cfinclude template="./export.cfm" >
					</cfcase> 
					<cfcase value="download">
						<cfinclude template="./download.cfm" >
					</cfcase> 
					<cfcase value="importfailed">
						<cfinclude template="./failed.cfm" >
					</cfcase> 
					<cfcase value="importcomplete">
						<cfinclude template="./complete.cfm" >
					</cfcase> 
					<cfcase value="import">
						<cfinclude template="./import.cfm" >
					</cfcase> 
					<cfdefaultcase>
						<cfinclude template="./home.cfm" >
					</cfdefaultcase>
				</cfswitch>

		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
				
</cfoutput></cfsavecontent>
<cfoutput>
#application.pluginManager.renderAdminTemplate(body=body,pageTitle=pluginConfig.getName())#
</cfoutput>
