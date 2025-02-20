#!/usr/bin/perl

use FindBin qw($RealBin);

use strict;

$|=1;

use Cwd;
use FileHandle;
use Getopt::Long;

#
# This is a script to convert the current oe-layersetup configs into
# the new XML format.  Current version only converts kirkstone, scarthgap, and
# master configs.
#

my $glRootDir = realpath("${RealBin}/../..");
my $glSrcDir = "${glRootDir}/src";
my $glSrcConfigsDir = "${glSrcDir}/configs";

my %glArgs;
$glArgs{distro} = "arago";
&GetOptions(\%glArgs,
            "input=s",
            "config-name=s",
            "distro=s",
            "import-existing",
            "force",
            "debug",
            "dry-run",
            "help"
           );

if (exists($glArgs{help}))
{
    usage();
    exit();
}


my %glReferencedBblayersConf;
my %glReferencedLocalConf;

if (exists($glArgs{input}))
{
    if (-f $glArgs{input})
    {
        convert_config($glArgs{input}, "input");
    }
    else
    {
        print STDERR "ERROR: --input points to an invalid file: $glArgs{input}\n";
        exit(1);
    }
}
elsif (exists($glArgs{'import-existing'}))
{
    convert_configs("${glRootDir}/configs");
}

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
    debug("convert_configs() - start");

    my $arDir = shift;

    debug("convert_configs() - arDir=$arDir");

    opendir(DIR, $arDir);
    my @loFiles = readdir(DIR);
    closedir(DIR);

    foreach my $lpFile (sort {$a cmp $b} @loFiles)
    {
        next if ($lpFile =~ /^\.\.?$/);

        debug("convert_configs() -   check: $arDir/$lpFile");

        if (-d "${arDir}/${lpFile}")
        {
            convert_configs("${arDir}/${lpFile}");
        }
        elsif ($lpFile =~ /\.txt$/)
        {
            convert_config("${arDir}/${lpFile}", "import");
        }
    }
    debug("convert_configs() - stop");
}

sub convert_config
{
    debug("convert_config() - start");

    my $arFile = shift;
    my $arMode = shift;
    
    debug("convert_config() -   arFile=${arFile}");
    debug("convert_config() -   arMode=${arMode}");

    my $loInputFileFPFN = realpath($arFile);

    debug("convert_config() -   loInputFileFPFN=${loInputFileFPFN}");

    my $loConfigName;
    if (exists($glArgs{'config-name'}) && ($arMode ne "import"))
    {
        $loConfigName = $glArgs{'config-name'};
    }
    else
    {
        $loConfigName = $loInputFileFPFN;
        $loConfigName =~ s{$glRootDir/}//;
        $loConfigName =~ s/^configs\///;
        $loConfigName =~ s/\.txt$//;
    }

    debug("convert_config() -   loConfigName=${loConfigName}");

    open(CFG, "${loInputFileFPFN}");
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

    #-------------------------------------------------------------------------
    # Setup the output file
    #-------------------------------------------------------------------------
    my $loTargetFPFN = "$glSrcConfigsDir/${loConfigName}.xml";

    debug("convert_config() -   loTargetFPFN=${loTargetFPFN}");

    my ($loTargetDir) = ($loTargetFPFN =~ /^(.+?)\/[^\/]+$/);

    print "convert: ${loInputFileFPFN} -> ${loTargetFPFN}\n";

    #-------------------------------------------------------------------------
    # Extract the templates so that we can convert them too.
    #-------------------------------------------------------------------------
    foreach my $lpLine (@loLines)
    {
        if ($lpLine =~ /^\s*OECORELAYERCONF\s*=\s*(.+?)$/)
        {
            my $loFile = $1;

            debug("convert_config() -   found bblayer.conf: ${loFile}");
            $glReferencedBblayersConf{realpath("${glRootDir}/${loFile}")} = 1;
        }

        if ($lpLine =~ /^\s*OECORELOCALCONF\s*=\s*(.+?)$/)
        {
            my $loFile = $1;

            debug("convert_config() -   found local.conf: ${loFile}");
            $glReferencedLocalConf{realpath("${glRootDir}/${loFile}")} = 1;
        }
    }

    if (!exists($glArgs{'dry-run'}))
    {
        system("mkdir -p ${loTargetDir}");
    }

    my @loMotd;
    my @loLocalConf;

    my $loDistro = "arago";
    
    if ($arMode ne "import")
    {
        $loDistro = $glArgs{distro};
    }

    if ($loTargetFPFN =~ /poky/)
    {
        $loDistro = "poky";
    }
    elsif ($loTargetFPFN =~ /distroless/)
    {
        $loDistro = "distroless";
    }

    debug("convert_config() -   loDistro=${loDistro}");

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

    debug("convert_config() -   loDescription=${loDescription}");

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
            debug("convert_config() -   lpLine = $lpLine");
        }
    }

    debug("convert_config() -   loTargetDir=${loTargetDir}");

    my $loRelSrcDir = $loTargetDir;
    $loRelSrcDir =~ s{$glSrcDir/}//;
    $loRelSrcDir =~ s/[^\/\.]/\.\./g;
    $loRelSrcDir =~ s/\.+/\.\./g;

    debug("convert_config() -   loRelSrcDir=${loRelSrcDir}");

    if ((-f $loTargetFPFN) && !exists($glArgs{force}))
    {
        print "  xml config alrady exists, skipping...\n";
        debug("convert_config() - stop - exists");
        return;
    }

    if (exists($glArgs{'dry-run'}))
    {
        open(XML, ">&STDOUT");
    }
    else
    {
        open(XML, ">$loTargetFPFN");
    }

    print XML "<?xml version='1.0'?>\n";
    print XML "<config>\n";
    print XML "    <description>${loDescription}</description>\n";
    print XML "\n";
    if ($#loMotd > -1)
    {
        print XML "    <xi:include href='${loRelSrcDir}/common/motd_cicd.xml' xmlns:xi='http://www.w3.org/2001/XInclude'/>\n";
    }
    if (-f "${glSrcDir}/common/targets_${loDistro}.xml")
    {
        print XML "    <xi:include href='${loRelSrcDir}/common/targets_${loDistro}.xml' xmlns:xi='http://www.w3.org/2001/XInclude'/>\n";
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

    debug("convert_config() - stop");
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
    debug("convert_local_conf_template() - start");

    my $arFile = shift;

    debug("convert_local_conf_template() -   arFile=${arFile}");

    my $loTargetFPFN = $arFile;
    $loTargetFPFN =~ s{^${glRootDir}/sample-files}/${glRootDir}\/src\/templates/;
    $loTargetFPFN =~ s/\.sample$/.xml/;

    debug("convert_local_conf_template() -   loTargetFPFN=${loTargetFPFN}");

    my ($loTargetFN) = ($loTargetFPFN =~ /\/([^\/]+).xml$/);

    debug("convert_local_conf_template() -   loTargetFN=${loTargetFN}");

    print "convert: ${arFile} -> ${loTargetFPFN}\n";

    my ($loTargetDir) = ($loTargetFPFN =~ /^(.+?)\/[^\/]+$/);

    debug("convert_local_conf_template() -   loTargetDir=${loTargetDir}");

    if (!exists($glArgs{'dry-run'}))
    {
        system("mkdir -p ${loTargetDir}");
    }

    open(CFG, $arFile);
    my @loLines = <CFG>;
    close(CFG);

    if ((-f $loTargetFPFN) && !exists($glArgs{force}))
    {
        print "  local_conf template already exists, skipping...\n";
        debug("convert_local_conf_template() - stop - exists");
        return;
    }

    if (exists($glArgs{'dry-run'}))
    {
        open(XML, ">&STDOUT");
    }
    else
    {
        open(XML, ">$loTargetFPFN");
    }

    print XML "<local-conf-template name='${loTargetFN}'>\n";

    foreach my $lpLine (@loLines)
    {
        chomp($lpLine);

        $lpLine =~ s/OEBASE/TOPDIR\/\.\./;
        $lpLine =~ s/^MACHINE/#MACHINE/;

        $lpLine =~ s/&/&amp;/g;
        $lpLine =~ s/</&lt;/g;
        $lpLine =~ s/>/&gt;/g;

        print XML "    <line>${lpLine}</line>\n";
    }

    print XML "</local-conf-template>\n";
    close(XML);

    debug("convert_local_conf_template() - stop");
}

sub convert_bblayers_conf_template
{
    debug("convert_bblayers_conf_template() - start");

    my $arFile = shift;

    debug("convert_bblayers_conf_template() -   arFile=${arFile}");

    my $loTargetFPFN = $arFile;
    $loTargetFPFN =~ s{^${glRootDir}/sample-files}/${glRootDir}\/src\/templates/;
    $loTargetFPFN =~ s/\.sample$/.xml/;

    debug("convert_bblayers_conf_template() -   loTargetFPFN=${loTargetFPFN}");

    my ($loTargetFN) = ($loTargetFPFN =~ /\/([^\/]+).xml$/);

    debug("convert_bblayers_conf_template() -   loTargetFN=${loTargetFN}");

    print "convert: ${arFile} -> ${loTargetFPFN}\n";

    my ($loTargetDir) = ($loTargetFPFN =~ /^(.+?)\/[^\/]+$/);

    debug("convert_bblayers_conf_template() -   loTargetDir=${loTargetDir}");

    if (!exists($glArgs{'dry-run'}))
    {
        system("mkdir -p ${loTargetDir}");
    }

    open(CFG, $arFile);
    my @loLines = <CFG>;
    close(CFG);

    if ((-f $loTargetFPFN) && !exists($glArgs{force}))
    {
        print "  bblayers_conf template already exists, skipping...\n";
        debug("convert_bblayers_conf_template() - stop - exists");
        return;
    }

    if (exists($glArgs{'dry-run'}))
    {
        open(XML, ">&STDOUT");
    }
    else
    {
        open(XML, ">$loTargetFPFN");
    }

    print XML "<bblayers-conf-template name='${loTargetFN}'>\n";

    foreach my $lpLine (@loLines)
    {
        chomp($lpLine);
        print XML "    <line>${lpLine}</line>\n";
    }

    print XML "</bblayers-conf-template>\n";
    close(XML);

    debug("convert_bblayers_conf_template() - stop");

}

sub debug
{
    if (exists($glArgs{debug}))
    {
        print @_,"\n";
    }
}

sub realpath
{
    my $rvRealPath = qx( realpath @_ );
    chomp($rvRealPath);
    return($rvRealPath);
}

sub usage
{
    print "$0\n";
    print "    --input <file> [--config-name <name> ] [--distro <distro>]\n";
    print "  or\n";
    print "    --import-existing\n";
    print "\n";
    print "  --input <file>         The oe-layersetup config to convert.  This file\n";
    print "                         does not need to be in the tree, but you probably\n";
    print "                         need to specify --config-name to tell the convert\n";
    print "                         script what the file name of the config will be.\n";
    print "\n";
    print "  --config-name <string> Relative dir name for the new config.  If the\n";
    print "                         config needs to reside in a subdirectory, then that\n";
    print "                         needs to be part of the name.  For example:\n";
    print "                           --config-name \"coresdk/coresdk-10.00.07-config.txt\"\n";
    print "\n";
    print "  --distro <string>      If the distro is not clear from the name of the\n";
    print "                         --input config, then you can specify the distro\n";
    print "                         that the config is targetting.\n";
    print "                           Default: \"arago\"\n";
    print "\n";
    print "  --import-existing      Convert all of the existing configs.  This was\n";
    print "                         meant to be a one-time run option, but is being\n";
    print "                         left in case it is needed in the future.\n";
    print "\n";
    print "  --force                If a config already exists with the name specified,\n";
    print "                         then it will bail and not reconvert it.  Use\n";
    print "                         --force to do the conversion anyway.\n";
    print "\n";
    print "  --dry-run              Do not modify anything, just print the conversion\n";
    print "                         to STDOUT.\n";
    print "\n";
    print "  --debug                Show debugging messages.\n";
    print "\n";
}

