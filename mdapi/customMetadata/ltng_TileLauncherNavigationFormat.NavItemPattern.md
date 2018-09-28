<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Nav Item Pattern</label>
    <protected>false</protected>
    <values>
        <field>Description__c</field>
        <value xsi:type="xsd:string">Navigates to pages specific to a record:

for example:
/n/MyCustomTabName

for more information, please see:
https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/components_navigation_page_definitions.htm#navigation_item</value>
    </values>
    <values>
        <field>Navigation_Object_Format__c</field>
        <value xsi:type="xsd:string">{
    &quot;type&quot;: &quot;standard__navItemPage&quot;,
    &quot;attributes&quot;: {
        &quot;apiName&quot;: &quot;&lt;%=_1%&gt;&quot;
    }
}</value>
    </values>
    <values>
        <field>Navigation_Type__c</field>
        <value xsi:type="xsd:string">Navigation Item Page</value>
    </values>
    <values>
        <field>Priority__c</field>
        <value xsi:type="xsd:double">100.0</value>
    </values>
    <values>
        <field>URL_Format__c</field>
        <value xsi:type="xsd:string">\/n\/([^/?]+)</value>
    </values>
</CustomMetadata>
