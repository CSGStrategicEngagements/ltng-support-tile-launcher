<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Knowledge Article Pattern</label>
    <protected>false</protected>
    <values>
        <field>Description__c</field>
        <value xsi:type="xsd:string">Navigates to a knowledge article

for example:
/lightning/articles/Briefings/February-2018

for more information, please see:
https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/components_navigation_page_definitions.htm#knowledge_article</value>
    </values>
    <values>
        <field>Navigation_Object_Format__c</field>
        <value xsi:type="xsd:string">{
    &quot;type&quot;: &quot;standard__knowledgeArticlePage&quot;,
    &quot;attributes&quot;: {
        &quot;articleType&quot;: &quot;&lt;%=_1%&gt;&quot;,
        &quot;urlName&quot;: &quot;&lt;%=_2%&gt;&quot;
    }
}</value>
    </values>
    <values>
        <field>Navigation_Type__c</field>
        <value xsi:type="xsd:string">Knowledge Article</value>
    </values>
    <values>
        <field>Priority__c</field>
        <value xsi:type="xsd:double">100.0</value>
    </values>
    <values>
        <field>URL_Format__c</field>
        <value xsi:type="xsd:string">\/articles\/([^/?]+)\/([^/?]+)</value>
    </values>
</CustomMetadata>
