<aura:application access="GLOBAL" extends="ltng:outApp" >
    <aura:dependency resource="c:ltng_TileLauncher" />
    <aura:dependency resource="c:ltng_TileLauncherTile" />
    <!-- not currently used, but added as a precaution -->
    <aura:dependency resource="c:ltng_HeroCarousel" />
    <aura:dependency resource="c:ltng_HeroButton" />
    <!-- Load the navigation events in the force namespace. -->
    <aura:dependency resource="markup://force:*" type="EVENT"/>
</aura:application>