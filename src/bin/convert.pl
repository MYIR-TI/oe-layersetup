#!/usr/bin/perl

use strict;

#
# This is a one-time script to convert the current oe-layersetup configs into
# the new XML format.  Current version only converts kirkstone, scarthgap, and
# master configs.
#
# NOTE: Paths are setup for this script to be run in the src/ directory
#

my %glReferencedBblayersConf;
my %glReferencedLocalConf;

convert_configs("configs");
#convert_templates("../sample-files");

foreach my $lpBblayersConf (keys(%glReferencedBblayersConf))
{
    convert_bblayers_conf_template($lpBblayersConf);
}

foreach my $lpLocalConf (keys(%glReferencedLocalConf))
{
    convert_local_conf_template($lpLocalConf);
}

sub convert_configs
{
    my $arDir = shift;

    #print "convert_configs: $arDir\n";

    opendir(DIR, "../${arDir}");
    my @loFiles = readdir(DIR);
    closedir(DIR);

    foreach my $lpFile (sort {$a cmp $b} @loFiles)
    {
        next if ($lpFile =~ /^\.\.?$/);

        #print "convert_configs: check: $arDir/$lpFile\n";

        if (-d "../${arDir}/${lpFile}")
        {
            convert_configs("${arDir}/${lpFile}");
        }
        elsif ($lpFile =~ /\.txt$/)
        {
            convert_config("${arDir}/${lpFile}");
        }
    }
}

sub convert_config
{
    my $arFile = shift;

    my $loConfigName = $arFile;
    $loConfigName =~ s/\.txt$//;
    $loConfigName =~ s/configs\///;

    my $loTargetFPFN = $arFile;
    $loTargetFPFN =~ s/\.txt$/.xml/;

    my ($loTargetDir) = ($loTargetFPFN =~ /^(.+?)\/[^\/]+$/);

    open(CFG, "../${arFile}");
    my @loLines = <CFG>;
    close(CFG);

    #-------------------------------------------------------------------------
    # Check if the config matches the right branches
    #-------------------------------------------------------------------------
    my $loMatchBranch = 0;
    foreach my $lpLine (@loLines)
    {
        if ($lpLine =~ /meta-ti/)
        {
            if ($lpLine =~ /(kirkstone|scarthgap|master)/)
            {
                $loMatchBranch = 1;
            }

            last;
        }
    }

    if ($loMatchBranch == 0)
    {
        return;
    }

    print "convert: ${arFile} -> ${loTargetFPFN}\n";

    #-------------------------------------------------------------------------
    # Extract the templates so that we can convert them too.
    #-------------------------------------------------------------------------
    foreach my $lpLine (@loLines)
    {
        if ($lpLine =~ /^\s*OECORELAYERCONF\s*=\s*(.+?)$/)
        {
            my $loFile = $1;

            $glReferencedBblayersConf{".".$loFile} = 1;
        }

        if ($lpLine =~ /^\s*OECORELOCALCONF\s*=\s*(.+?)$/)
        {
            my $loFile = $1;

            $glReferencedLocalConf{".".$loFile} = 1;
        }
    }

    system("mkdir -p ${loTargetDir}");

    my @loMotd;
    my @loLocalConf;

    my $loTargets = "arago";

    if ($loTargetFPFN =~ /poky/)
    {
        $loTargets = "poky";
    }
    elsif ($loTargetFPFN =~ /distroless/)
    {
        $loTargets = "distroless";
    }

    my $loDescription = "";

    if ($loConfigName =~ /^arago-(.+)-config/)
    {
        my $loBranch = $1;
        $loDescription = "Arago reference distribution for $loBranch";

        if ($loBranch =~ /-next$/)
        {
            $loDescription .= " (CICD)";
        }
    }
    elsif ($loConfigName =~ /^poky-(.+)-config/)
    {
        my $loBranch = $1;
        $loDescription = "Poky reference distribution for $loBranch";
    }
    elsif ($loConfigName =~ /^distroless-(.+)-config/)
    {
        my $loBranch = $1;
        $loDescription = "Distroless reference for $loBranch";
    }
    elsif ($loConfigName =~ /^amsdk\/amsdk-(.+)-config/)
    {
        my $loVersion = $1;
        $loDescription = "TI AMSDK v$loVersion";
    }
    elsif ($loConfigName =~ /^coresdk\/coresdk-(.+)-config/)
    {
        my $loVersion = $1;
        $loDescription = "TI CoreSDK v$loVersion";
    }
    elsif ($loConfigName =~ /^glsdk\/glsdk-(.+)-config/)
    {
        my $loVersion = $1;
        $loDescription = "TI GLSDK v$loVersion";
    }
    elsif ($loConfigName =~ /^mcsdk\/mcsdk-(.+)-config/)
    {
        my $loVersion = $1;
        $loDescription = "TI MCSDK v$loVersion";
    }
    elsif ($loConfigName =~ /^processor-sdk\/processor-sdk(?:-(?:dunfell|kirkstone|kirkstone-chromium|scarthgap|scarthgap-chromium))?-(.+?)(-config)?$/)
    {
        my $loVersion = $1;
        $loDescription = "TI Processor SDK v$loVersion";
    }
    elsif ($loConfigName =~ /^processor-sdk-analytics\/processor-sdk-analytics-(.+?)(-config)?$/)
    {
        my $loVersion = $1;
        $loDescription = "TI Processor SDK Analytics v$loVersion";
    }
    elsif ($loConfigName =~ /^processor-sdk-linux\/processor-sdk(?:-(?:linux|gateway))?-(.+?)(-config)?$/)
    {
        my $loVersion = $1;
        $loDescription = "TI Processor SDK Linux v$loVersion";
    }

    my $loLayerConfTemplate = "";
    my $loLocalConfTemplate = "";
    my $loBitbakeInclusiveVars = "no";

    my %loBitbake;
    my @loRepos;

    foreach my $lpLine (@loLines)
    {
        chomp($lpLine);

        next if (($lpLine =~ /^#/) && ($lpLine !~/^#\s*meta/));
        next if ($lpLine =~ /^\s*$/);

        if ($lpLine =~ /^OECORELAYERCONF\s*=\s*\.\/sample-files\/(.+?)$/)
        {
            $loLayerConfTemplate = $1;
            $loLayerConfTemplate =~ s/\.sample$/.xml/;
        }
        elsif ($lpLine =~ /^OECORELOCALCONF\s*=\s*\.\/sample-files\/(.+?)$/)
        {
            $loLocalConfTemplate = $1;
            $loLocalConfTemplate =~ s/\.sample$/.xml/;
        }
        elsif ($lpLine =~ /^BITBAKE_INCLUSIVE_VARS\s*=\s*(.+?)$/)
        {
            $loBitbakeInclusiveVars = $1;
        }
        elsif ($lpLine =~ /^MOTD:\s*(.+?)$/)
        {
            push(@loMotd, $1);
        }
        elsif ($lpLine =~ /^LOCALCONF:\s*(.+?)$/)
        {
            push(@loLocalConf, $1);
        }
        elsif ($lpLine =~ /^bitbake/)
        {
            extract_repo(\%loBitbake, $lpLine);
        }
        elsif ($lpLine =~ /^[^,]+,[^,]+,[^,]+,[^,]+/)
        {
            my %loRepo;
            extract_repo(\%loRepo, $lpLine);
            push(@loRepos, \%loRepo);
        }
        else
        {
            print "convert_config() -   lpLine = $lpLine\n";
        }
    }


    my $loRelSrcDir = $loTargetDir;
    $loRelSrcDir =~ s/[^\/\.]/\.\./g;
    $loRelSrcDir =~ s/\.+/\.\./g;

    open(XML, ">$loTargetFPFN");
    print XML "<?xml version='1.0'?>\n";
    print XML "<config>\n";
    print XML "    <description>${loDescription}</description>\n";
    print XML "\n";
    if ($#loMotd > -1)
    {
        print XML "    <xi:include href='${loRelSrcDir}/common/motd_cicd.xml' xmlns:xi='http://www.w3.org/2001/XInclude'/>\n";
    }
    if (-f "common/targets_${loTargets}.xml")
    {
        print XML "    <xi:include href='${loRelSrcDir}/common/targets_${loTargets}.xml' xmlns:xi='http://www.w3.org/2001/XInclude'/>\n";
    }
    print XML "    <xi:include href='${loRelSrcDir}/templates/${loLayerConfTemplate}' xmlns:xi='http://www.w3.org/2001/XInclude'/>\n";
    print XML "    <xi:include href='${loRelSrcDir}/templates/${loLocalConfTemplate}' xmlns:xi='http://www.w3.org/2001/XInclude'/>\n";
    print XML "\n";
    print XML "    <bitbake url='".$loBitbake{url}."' branch='".$loBitbake{branch}."' commit='".$loBitbake{commit}."'/>\n";
    print XML "\n";
    print XML "    <repos>\n";

    foreach my $lpRepo (@loRepos)
    {
        print XML "        <repo name='$lpRepo->{name}' url='$lpRepo->{url}' branch='$lpRepo->{branch}' commit='$lpRepo->{commit}'";
        if (exists($lpRepo->{disabled}))
        {
            print XML " disabled='$lpRepo->{disabled}'";
        }
        print XML ">\n";
        if (exists($lpRepo->{layers}))
        {
            if ($#{$lpRepo->{layers}} == -1)
            {
                print XML "            <layers/>\n";
            }
            else
            {
                print XML "            <layers>\n";
                foreach my $lpLayer (@{$lpRepo->{layers}})
                {
                    print XML "                <layer>${lpLayer}</layer>\n";
                }
                print XML "            </layers>\n";
            }
        }
        print XML "        </repo>\n";
    }

    print XML "    </repos>\n";
    print XML "\n";
    if ($#loLocalConf > -1)
    {
        print XML "    <local-conf>\n";
        foreach my $lpLocalConfLine (@loLocalConf)
        {
            print XML "        <line>${lpLocalConfLine}</line>\n";
        }
        print XML "    </local-conf>\n";
        print XML "\n";
    }
    print XML "    <tools>\n";
    print XML "        <tool type='oe-layersetup'>\n";
    print XML "            <var name='BITBAKE_INCLUSIVE_VARS' value='${loBitbakeInclusiveVars}'/>\n";
    print XML "        </tool>\n";
    print XML "    </tools>\n";
    print XML "</config>\n";
    close(XML);
}

sub extract_repo
{
    my $rvRepoHash = shift;
    my $arLine = shift;

    my ($loRepo, $loUrl, $loBranch, $loCommit, $loLayers) = split(",",$arLine);

    if ($loRepo =~ /^#/)
    {
        $rvRepoHash->{disabled} = "true";
        $loRepo =~ s/^#//;
    }

    $rvRepoHash->{name} = $loRepo;
    $rvRepoHash->{url} = $loUrl;
    $rvRepoHash->{branch} = $loBranch;
    $rvRepoHash->{commit} = $loCommit;

    if ($loLayers)
    {
        $loLayers =~ s/layers=//;
        $rvRepoHash->{layers} = [ split(":",$loLayers) ];
    }
}

sub convert_local_conf_template
{
    my $arFile = shift;

    my $loTargetFPFN = $arFile;
    $loTargetFPFN =~ s/^\.\.\/sample-files/templates/;
    $loTargetFPFN =~ s/\.sample$/.xml/;
    my ($loTargetFN) = ($loTargetFPFN =~ /^templates\/(.+).xml$/);

    print "convert: ${arFile} -> ${loTargetFPFN}\n";

    my ($loTargetDir) = ($loTargetFPFN =~ /^(.+?)\/[^\/]+$/);

    system("mkdir -p ${loTargetDir}");

    open(CFG, $arFile);
    my @loLines = <CFG>;
    close(CFG);

    open(XML, ">$loTargetFPFN");
    print XML "<local-conf-template name='${loTargetFN}'>\n";

    foreach my $lpLine (@loLines)
    {
        chomp($lpLine);

        $lpLine =~ s/OEBASE/TOPDIR/;
        $lpLine =~ s/^MACHINE/#MACHINE/;

        $lpLine =~ s/&/&amp;/g;
        $lpLine =~ s/</&lt;/g;
        $lpLine =~ s/>/&gt;/g;

        print XML "    <line>${lpLine}</line>\n";
    }

    print XML "</local-conf-template>\n";
    close(XML);
}

sub convert_bblayers_conf_template
{
    my $arFile = shift;

    my $loTargetFPFN = $arFile;
    $loTargetFPFN =~ s/^\.\.\/sample-files/templates/;
    $loTargetFPFN =~ s/\.sample$/.xml/;
    my ($loTargetFN) = ($loTargetFPFN =~ /^templates\/(.+).xml$/);

    print "convert: ${arFile} -> ${loTargetFPFN}\n";

    my ($loTargetDir) = ($loTargetFPFN =~ /^(.+?)\/[^\/]+$/);

    system("mkdir -p ${loTargetDir}");

    open(CFG, $arFile);
    my @loLines = <CFG>;
    close(CFG);

    open(XML, ">$loTargetFPFN");
    print XML "<bblayers-conf-template name='${loTargetFN}'>\n";

    foreach my $lpLine (@loLines)
    {
        chomp($lpLine);
        print XML "    <line>${lpLine}</line>\n";
    }

    print XML "</bblayers-conf-template>\n";
    close(XML);
}

