{**
 * issueToc.tpl
 *
 * Copyright (c) 2003-2011 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * Display the issue's table of contents
 *
 * $Id$
 *}
{strip}
{if not $noIssue}
	{assign var="pageTitleTranslated" value=$issue->getIssueIdentification()|escape}
	{assign var="pageCrumbTitleTranslated" value=$issue->getIssueIdentification(false,true)|escape}
{else}
	{assign var="pageTitle" value="editor.issues.noLiveIssues"}
	{assign var="pageCrumbTitle" value="editor.issues.noLiveIssues"}
{/if}
{include file="common/header.tpl"}
{/strip}

<script type="text/javascript">
{literal}
$(document).ready(function() {
	{/literal}{foreach from=$sections key=sectionKey item=section}{literal}
	setupTableDND("#issueToc-{/literal}{$sectionKey|escape}{literal}", "{/literal}{url|escape:"jsparam" op=moveArticleToc escape=false}{literal}");
	{/literal}{/foreach}{literal}
}); 
{/literal}
</script>
<script type="text/javascript">
	{literal}
	function validateAnd_confirmAction(param1, param2){
	     if ($('#issueRights').is(":checked")){	
	         confirmAction(param1, param2);
	      }
	      else{
	      	alert('You must acknowledge the Deposit Agreement before publishing this issue.');
		return false;
	       }		
	}
	{/literal}
</script>

{if !$isLayoutEditor}{* Layout Editors can also access this page. *}
	<ul class="menu">
		{* 20111201 BLH Hide 'Create Issue' link for UEE *}
		{if $journalPath != 'nelc_uee' || $isSiteAdmin}
			<li><a href="{url op="createIssue"}">{translate key="editor.navigation.createIssue"}</a></li>
		{/if}	
        {* 20111201 BLH Diplay 'Unpublished Content' & 'Published Content' for UCLA Encyclopedia of Egyptology*}
		{* 20120502 LS Display only 'Published Content' for UEE *}
        {if $journalPath == 'nelc_uee'}
        	<li{if !$unpublished} class="current"{/if}><a href="{url op="backIssues"}">{translate key="editor.navigation.publishedContent"}</a></li>
        {else}
        	<li{if $unpublished} class="current"{/if}><a href="{url op="futureIssues"}">{translate key="editor.navigation.futureIssues"}</a></li>
        	<li{if !$unpublished} class="current"{/if}><a href="{url op="backIssues"}">{translate key="editor.navigation.issueArchive"}</a></li>
        {/if}
	</ul>
{/if}

{if not $noIssue}
<br />

<form action="#">
{translate key="issue.issue"}: <select name="issue" class="selectMenu" onchange="if(this.options[this.selectedIndex].value > 0) location.href='{url|escape:"javascript" op="issueToc" path="ISSUE_ID" escape=false}'.replace('ISSUE_ID', this.options[this.selectedIndex].value)" size="1">{html_options options=$issueOptions|truncate:40:"..." selected=$issueId}</select>
</form>

<div class="separator"></div>

<ul class="menu">
	<li class="current"><a href="{url op="issueToc" path=$issueId}">{translate key="issue.toc"}</a></li>
	<li><a href="{url op="issueData" path=$issueId}">{translate key="editor.issues.issueData"}</a></li>
	{* 20120502 LS Removing 'Preview Issue' link *}
	{* {if $unpublished}<li><a href="{url page="issue" op="view" path=$issue->getBestIssueId()}">{translate key="editor.issues.previewIssue"}</a></li>{/if} *}
	{call_hook name="Templates::Editor::Issues::IssueToc::IssuePages"}
</ul>

<h3>{translate key="issue.toc"} <a href="https://submit.escholarship.org/help/journals/editors_x.html" target="_blank"><img src="{$baseUrl}/eschol/images/help_A.png"></a></h3>
{url|assign:"url" op="resetSectionOrder" path=$issueId}
{if $customSectionOrderingExists}{translate key="editor.issues.resetSectionOrder" url=$url}<br/>{/if}
{if $unpublished}
	{assign var="updateCheckKey" value="editor.issues.saveChanges"}
{else}
	{assign var="updateCheckKey" value="editor.issues.saveAndPublishChanges"}
{/if}

<form method="post" action="{url op="updateIssueToc" path=$issueId}">

{assign var=numCols value=6}
{if $issueAccess == $smarty.const.ISSUE_ACCESS_SUBSCRIPTION && $currentJournal->getSetting('publishingMode') == $smarty.const.PUBLISHING_MODE_SUBSCRIPTION}{assign var=numCols value=$numCols+1}{/if}
{if $enablePublicArticleId}{assign var=numCols value=$numCols+1}{/if}
{if $enablePageNumber}{assign var=numCols value=$numCols+1}{/if}

{assign var="missingGalleys" value=false}
{foreach from=$sections key=sectionKey item=section}
<h4>{$section[1]}{if $section[4]}<a href="{url op="moveSectionToc" path=$issueId d=u newPos=$section[4] sectionId=$section[0]}" class="plain">&uarr;</a>{else}&uarr;{/if} {if $section[5]}<a href="{url op="moveSectionToc" path=$issueId d=d newPos=$section[5] sectionId=$section[0]}" class="plain">&darr;</a>{else}&darr;{/if}</h4>

<table width="100%" class="listing" id="issueToc-{$sectionKey|escape}">
	<tr>
		<td colspan="{$numCols|escape}" class="headseparator">&nbsp;</td>
	</tr>
	<tr class="heading" valign="bottom">
		<td width="5%">&nbsp;</td>
		<td width="15%">{translate key="article.authors"}</td>
		<td>{translate key="article.title"}</td>
		{if $issueAccess == $smarty.const.ISSUE_ACCESS_SUBSCRIPTION && $currentJournal->getSetting('publishingMode') == $smarty.const.PUBLISHING_MODE_SUBSCRIPTION}<td width="10%">{translate key="editor.issues.access"}</td>{/if}
		{if $enablePublicArticleId}<td width="7%">{translate key="editor.issues.publicId"}</td>{/if}
		{if $enablePageNumber}<td width="7%">{translate key="editor.issues.pages"}</td>{/if}
		{if $unpublished || $isSiteAdmin}<td width="5%">{translate key="common.remove"}</td>{/if} {* BLH 20111021 For unpublished issues, hide for all but site admin *}
		<td width="10%">{translate key="editor.issues.proofed"}</td>
                <td width="7%">HAS GALLEY</td>
	</tr>
	<tr>
		<td colspan="{$numCols|escape}" class="headseparator">&nbsp;</td>
	</tr>

	{assign var="articleSeq" value=0}
	{foreach from=$section[2] item=article name="currSection"}

	{assign var="articleSeq" value=$articleSeq+1}
	{assign var="articleId" value=$article->getId()}
	<tr id="article-{$article->getPubId()|escape}" class="data">
		<td><a href="{url op="moveArticleToc" d=u id=$article->getPubId()}" class="plain">&uarr;</a>&nbsp;<a href="{url op="moveArticleToc" d=d id=$article->getPubId()}" class="plain">&darr;</a></td>
		<td>
			{foreach from=$article->getAuthors() item=author name=authorList}
				{$author->getLastName()|escape}{if !$smarty.foreach.authorList.last},{/if}
			{/foreach}
		</td>
		{*<td class="drag">{if !$isLayoutEditor}<a href="{url op="submission" path=$articleId}" class="action">{/if}{$article->getLocalizedTitle()|strip_tags|truncate:60:"..."}{if !$isLayoutEditor}</a>{/if}</td>*}
		<td class="drag">{if !$isLayoutEditor}<a href="{url op="submission" path=$articleId}" class="action">{/if}{$article->getLocalizedTitle()}{if !$isLayoutEditor}</a>{/if}</td>{* 20111214 BLH Remove formatting - it was replacing entire title with "...". Will fix properly later. *}
		{if $issueAccess == $smarty.const.ISSUE_ACCESS_SUBSCRIPTION && $currentJournal->getSetting('publishingMode') == $smarty.const.PUBLISHING_MODE_SUBSCRIPTION}
		<td><select name="accessStatus[{$article->getPubId()}]" size="1" class="selectMenu">{html_options options=$accessOptions selected=$article->getAccessStatus()}</select></td>
		{/if}
		{if $enablePublicArticleId}
		<td><input type="text" name="publishedArticles[{$article->getId()}]" value="{$article->getPublicArticleId()|escape}" size="7" maxlength="255" class="textField" /></td>
		{/if}
		{if $enablePageNumber}<td><input type="text" name="pages[{$article->getId()}]" value="{$article->getPages()|escape}" size="7" maxlength="255" class="textField" /></td>{/if}
		{if $unpublished || $isSiteAdmin}<td><input type="checkbox" name="remove[{$article->getId()}]" value="{$article->getPubId()}" /></td>{/if} {* BLH 20111021 For unpublished issues, hide for all but site admin *}
		<td>
			{if in_array($article->getId(), $proofedArticleIds)}
				{icon name="checked"}
			{else}
				{icon name="unchecked"}
			{/if}
                </td>
                <td>
                        {assign var="galleyExists" value=false}
                        {foreach name=galleys from=$article->getGalleys() item=galley}
                            {assign var="galleyExists" value=true}
                        {/foreach}
                        {if $galleyExists}
                            {icon name="checked"} 
                        {else}
                            {icon name="unchecked"}
                            {assign var="missingGalleys" value=true}
                        {/if}
		</td>
	</tr>
	{/foreach}
</table>
{foreachelse}
<p><em>{translate key="editor.issues.noArticles"}</em></p>

<div class="separator"></div>
{/foreach}

<br/>
	
<h2>Deposit Agreement</h2>
<p><input type="checkbox" id="issueRights"/>* I have received permission from at least one author of each article in this issue to publish the items listed above. For articles submitted by the author using eScholarship's submission management system, I understand that the submitter granted permission at the time of deposit. For all other items, I have received paper or electronic documentation that an author has agreed to the journal’s author agreement. (If you have questions about this agreement, contact <a href="mailto:help@escholarship.org">help@escholarship.org</a>.)</strong></p>
<br/><br/>

{if $unpublished}
	<!-- save button -->
	<input type="submit" value="{translate key="common.save"}" class="button defaultButton" />
	{if $isSiteAdmin || (!$isLayoutEditor && !$escholInStage && $journalPath != 'ethnomusic_pre' && $issueTitle != 'Unpublished')}
		<!-- publish -->
		<input type="button" value="{translate key="editor.issues.publishIssue"}" onclick="return validateAnd_confirmAction('{url op="publishIssue" path=$issueId}', '{translate|escape:"jsparam" key="editor.issues.confirmPublish"}')" class="button" {if $missingGalleys==true}disabled="disabled"{/if} />
	{/if}
{else}
	<!-- 'update published issue' button -->
	<input type="submit" value="{translate key="editor.issues.saveAndPublishIssue"}" onclick="return validateAnd_confirmAction('{url op="updateIssueToc" path=$issueId}', 'Are you sure you want to update this published issue?')" {if $missingGalleys==true}class="button" disabled="disabled"{else}class="button defaultButton"{/if} />
	{if $isSiteAdmin}
		<!-- unpublish button -->
		<input type="button" value="{translate key="editor.issues.unpublishIssue"}" onclick="confirmAction('{url op="unpublishIssue" path=$issueId}', '{translate|escape:"jsparam" key="editor.issues.confirmUnpublish"}')" class="button" />	
	{/if}
{/if}

{if $missingGalleys==true}
    {if $unpublished}
        {assign var="publishedOrUpdated" value="published"}
    {else}
        {assign var="publishedOrUpdated" value="updated"}
    {/if}	
    <p style="padding: 5px; background: #F0B1A8;">Issue cannot be {$publishedOrUpdated} because one or more articles do not have galleys. To add a galley, click on the article title above and upload a file in the "3. EDITING --&gt; Layout" section.</p>
{/if}

<p><strong>Please allow up to 30 minutes for your issue to appear publicly.<br/>Still having trouble publishing this issue? <a href="https://help.escholarship.org/support/solutions/articles/9000067815-i-just-tried-to-publish-a-journal-issue-but-it-isn-t-showing-up-on-escholarship-org-or-only-some-of-" target="_blank">Click here for help</a>.</strong> </p>
</form>

{/if}

{include file="common/footer.tpl"}

