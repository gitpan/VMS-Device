package VMS::Device;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require DynaLoader;
require AutoLoader;

@ISA = qw(Exporter AutoLoader DynaLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw();
@EXPORT_OK = qw(&device_types &device_classes &device_list &device_info
                &decode_device_bitmap &device_info_item &mount &dismount
                &allocate &deallocate &initialize);
$VERSION = '0.08';

bootstrap VMS::Device $VERSION;

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

VMS::Device - Perl interface to VMS device system calls ($GETDVI and friends)

=head1 SYNOPSIS

  use VMS::Device;
  @type_list = device_types();
  @class_list = device_classes();
  @dev_list = device_list($DeviceName[, $DeviceClass[, $DeviceType]]);
  $DevInfoHashRef = device_info($DeviceName);
  $BitmapHashRef = decode_device_bitmap($InfoName, $BitmapValue)
  $Status = mount(\%Device_properties);
  $Status = dismount($DevName[, \%Dismount_flags]); [Unimplemented]
  $DeviceAllocated = allocate($DevName[, $FirstAvail[, $AccMode]]);
  $Status = deallocate($DevName[, $AccMode]);
  $Status = initialize($DevName[, $VolumeName[, \%DevProperties]]);

=head1 DESCRIPTION

VMS::Device mounts and dismounts, allocates and deallocates, initializes,
and lists and gets info on devices. It subsumes the DCL commands MOUNT,
DISMOUNT, ALLOCATE, DEALLOCATE, and INITIALIZE, as well as the lexical
functions F$DEVICE and F$GETDVI.

=head2 Functions

=item device_types

This function returns a list of all the valid device types that can be
specified for the C<device_list> function.

=item device_classes

This function returns a list of all the valid device classes that can be
specified for the C<device_list> function.

=item device_list

The C<device_list> function returns a list of all devices whose names match
the passed device name (Standard VMS wildcards of * and % are OK) and that
meets the criteria in the optional device type and device class.

Both the device class and device type may be ommitted if you want, or
passed as C<undef>. If you use the type and not the class, class must be
passed as C<undef>.

=item device_info

The C<device_info> function returns a reference to a hash containing all
the information available about the device you asked about.

=item decode_device_bitmap

The C<decode_device_bitmap> takes an item code and an integer, and returns
a reference to a hash. The function assumes the integer is a bitmap as
returned for that particular item, and decodes it. Each element in the
returned hash is equivalent to one of the bits in the integer--its value
will be true or false depending on the setting of the bit.

=item mount

C<mount> takes a reference to a hash with the parameters for the mount, and
attempts to mount the device. At the very least you want a C<DEVNAM>
parameter to specify the device being mounted.

=item dismount

C<dismount> dismounts the specified device. The optional reference to a
flag hash governs how the dismount behaves (whether it's a cluster-wide
dismount, for example)

=item allocate

C<allocate> allocates the named device.

If the C<$FirstAvail> flag is true, then the device name is treated as a
device type rather than an actual device, and the first device matching the
type that's available will be allocated.

C<$AccMode> is the access mode that the device is allocated in. This can be
one of:

    KERNEL
    EXEC
    SUPER
    USER

to indicate the mode the device should be allocated in.

=item deallocate

C<deallocate> deallocates a previously allocated device. The optional
second parameter can be one of:

    KERNEL
    EXEC
    SUPER
    USER

to indicate the mode the device should be deallocated in.

=item initialize

Initializes the specified device. If the second parameter isn't C<undef>,
it's taken to be the name the initialized volume should have. If the third
parameter isn't C<undef>, it's taken to be a reference to a hash that has
the properties the newly-initialized volume should have.

=head1 EXAMPLES

Here's a sample that returns the total amount of free space on all disk
devices:

    #! perl -w
    use VMS::Device qw(device_list device_info);

    $TotalFreeBlocks = 0;
    foreach my $devname (device_list("*", "DISK")) {
      $TotalFreeBlocks += device_info($devname)->{FREEBLOCKS};
    }

    print "Total free is $TotalFreeBlocks\n";


here's one that prints out the disk with the largest amount of free space:

    #! perl -w
    use VMS::Device qw(device_list device_info);

    $FreeBlocks = 0;
    $FreeName = "DUAWHOKNOWS";
    foreach my $devname (device_list("*", "DISK")) {
      $CheckBlocks = device_info($devname)->{FREEBLOCKS};
      if ($CheckBlocks > $FreeBlocks) {
        $FreeBlocks = $CheckBlocks;
        $FreeName = $devname;
      }
    }

    print "$FreeBlocks on $FreeName\n";


and here's one that shows all disks with less than 10% free:


    #! perl -w
    use VMS::Device qw(device_list device_info decode_device_bitmap);
    
    foreach my $devname (device_list("*", "DISK")) {
      $DevHash = device_info($devname);
      $FreeBlocks = $DevHash->{FREEBLOCKS};
      $MaxBlocks = $DevHash->{MAXBLOCK};
      next unless $DevHash->{MOUNTCNT};
      next unless $MaxBlocks;
      $PctFree = int(($FreeBlocks/$MaxBlocks) * 100);
      if ($PctFree < 10) {
        print "Only $PctFree\% on $devname ($FreeBlocks of $MaxBlocks)\n";
      }
    }

=head1 AUTHOR

Dan Sugalski <sugalskd@ous.edu>

=head1 SEE ALSO

perl(1).

=cut
                                                                                                                                                                                                                                                                                                                     dung 0
  107178 Friedens 0
  107178 Freiheit 0
  107178 Frigg 0
  107178 Frija 0
  107178 Gottheiten 0
  107178 Vorsitz 0
  107178 Gesamtheit 0
  107178 Runen 0
  107178 Bedeutung 0
  107178 Um 0
  107178 Aett 0
  107178 Deshalb 0
  107178 Form 0
  107178 Beziehung 0
  107178 Fehu 0
  107178 Element 0
  107178 Auch 0
  107178 Goden 0
  107178 Hiesen 0
  107178 Priester 0
  107178 Freysgodi 0
  107178 Njordr 0
  107178 Odin 0
  107178 Trunk 0
  107178 Hladir 0
  107178 Jarle 0
  107178 Opferfeiern 0
  107178 Bei 0
  107178 Ring 0
  107178 Schwedenferkel 0
  107178 Sviagriss 0
  107178 Konige 0
  107178 Reichskleinod 0
  107178 Das 0
  107178 Freysopfer 0
  107178 Frosblot 0
  107178 Freyrskult 0
  107178 Ostschweden 0
  107178 Ortsnamen 0
  107178 Schweden 0
  107178 In 0
  107178 Wahnsinn 0
  107178 Lebensenergie 0
  107178 Feuers 0
  107178 Kraft 6
  107178 Diesem 0
  107178 Liebschaften 0
  107178 Neben 0
  107178 Skirnirlied 0
  107178 Bundnis 0
  107178 Wie 0
  107178 Pflanzenwelt 0
  107178 Eis 0
  107178 Schnee 0
  107178 Naturmythologisch 0
  107178 Gymir 0
  107178 Riesen 0
  107178 Gerda 4
  107178 Gottin 0
  107178 Frau 0
  107178 Gelubde 0
  107178 Stammen 0
  107178 Opfer 0
  107178 Herdenebers 0
  107178 Borsten 0
  107178 Handauflegen 0
  107178 Julfest 0
  107178 Zum 0
  107178 Pferd 0
  107178 Hirsch 0
  107178 Krafttiere 0
  107178 Past 0
  107178 Tasche 0
  107178 Platz 0
  107178 Pferden 0
  107178 Gotter 0
  107178 Welt 0
  107178 Faltboot 0
  107178 Ihm 0
  107178 Name 0
  107178 Slidrugtanni 0
  107178 Gullinbursti 0
  107178 Eber 0
  107178 Ebers 0
  107178 Hindernis 0
  107178 Schimmelhengstes 0
  107178 Weiterhin 0
  107178 Brautschau 0
  107178 Skirnir 0
  107178 Feuerriesen 0
  107178 Surtr 0
  107178 Kampf 0
  107178 Ragnarok 0
  107178 Dieses 0
  107178 Skidbladnir 0
  107178 Hand 0
  107178 Furchtlosen 0
  107178 Schwertes 0
  107178 Besitz 0
  107178 Wohnsitz 0
  107178 Freyrs 0
  107178 Elbenheim 0
  107178 Alfheim 0
  107178 Fesseln 0
  107178 Wohlstand 0
  107178 Menschen 0
  107178 Land 0
  107178 Vorgange 0
  107178 Ekstase 0
  107178 Gott 4
  107178 Pan 0
  107178 Carnun 0
  107178 Schliesen 0
  107178 Last 0
  107178 Penis 0
  107178 Groser 0
  107178 Sein 0
  107178 Seine 0
  107178 Erotik 0
  107178 Wohlergehen 0
  107178 Reichtum 0
  107178 Gylfaginning 0
  107178 Heist 0
  107178 So 0
  107178 Frieden 0
  107178 Fruchtbarkeit 1
  107178 Erde 0
  107178 Wachstum 0
  107178 Sonnenschein 0
  107178 Regen 0
  107178 Er 1
  107178 Vanen 0
  107178 Antlitz 0
  107178 Sie 0
  107178 Freyja 1
  107178 Tochter 0
  107178 Freyr 14
  107178 Hies 0
  107178 Sohn 0
  107178 Der 0
  107178 Kinder 19
  107178 Nerthus 19
  107178 Njord 19
    2440 Finland 12
    2440 Investing 12
    2440 Business 12
    2440 Lists 12
    2440 Directories 12
    2440 World 0
    2440 Catalog 0
    2440 Logo 0
    2440 Reserved 0
    2440 Rights 0
    2440 Aaltonen 0
    2440 Kimmo 0
    2440 Canada 0
    2440 Sweden 0
    2440 Europe 0
    2440 Finnish 0
    2440 Loads 0
    2440 Dodgers 0
    2440 Millennium 0
    2440 Madtv 0
    2440 Fox 0
    2440 Reunion 0
    2440 Ring 0
    2440 Haven 0
    2440 Milano 0
    2440 Stockholm 0
    2440 Atlanta 0
    2440 Garden 0
    2440 Square 0
    2440 Madison 0
    2440 Brooklyn 0
    2440 Video 0
    2440 Tiger 0
    2440 Melbourne 0
    2440 Nagoya 0
    2440 Paolo 0
    2440 Sao 0
    2440 Kissaholics 0
    2440 London 0
    2440 Comet 0
    2440 Or 0
    2440 Dead 0
    2440 Wanted 0
    2440 Runaway 0
    2440 Kulick 0
    2440 Janeiro 0
    2440 Rio 0
    2440 Dutch 0
    2440 Loud 0
    2440 It 0
    2440 Countdown 0
    2440 Sydney 0
    2440 Anaheim 0
    2440 Francisco 0
    2440 San 0
    2440 Coming 0
    2440 Konfidential 0
    2440 Xtreme 0
    2440 Exposed 0
    2440 Official 0
    2440 Helsinki 0
    2440 Angeles 0
    2440 Los 0
    2440 Circus 0
    2440 Halloween 0
    2440 Arena 0
    2440 Globe 0
    2440 Donington 0
    2440 Dayton 0
    2440 Golden 0
    2440 Dancemix 0
    2440 Acoustic 0
    2440 Secret 0
    2440 York 0
    2440 New 0
    2440 Back 0
    2440 Pony 0
    2440 Hits 0
    2440 Monsters 0
    2440 Oulu 0
    2440 Lakeland 0
    2440 Houston 0
    2440 Destroyes 0
    2440 Epic 0
    2440 Lester 0
    2440 Wicked 0
    2440 Original 0
    2440 Box 0
    2440 Budokan 0
    2440 Kamikaze 0
    2440 St 0
    2440 Demos 1
    2440 Fancy 0
    2440 Sanctum 0
    2440 Inner 0
    2440 Australia 0
    2440 France 0
    2440 French 0
    2440 Bootleg 0
    2440 Fifteen 0
    2440 Radio 0
    2440 Promo 0
    2440 Everytime 0
    2440 Forever 0
    2440 Florida 0
    2440 Gimme 0
    2440 Young 0
    2440 Not 0
    2440 Killer 0
    2440 Cold 0
    2440 Nowhere 0
    2440 Save 0
    2440 Magic 0
    2440 Dirty 0
    2440 See 0
    2440 Beth 0
    2440 Nothin 0
    2440 Calling 0
    2440 Who 0
    2440 Thief 0
    2440 Reason 0
    2440 Trial 0
    2440 Uh 0
    2440 Burn 0
    2440 Thrills 0
    2440 Lonely 0
    2440 Bside 0
    2440 Aside 0
    2440 Hard 0
    2440 Japanese 0
    2440 Originals 0
    2440 Gatefold 0
    2440 White 0
    2440 Strutter 0
    2440 Deuce 0
    2440 Partners 0
    2440 Unholy 0
    2440 Red 0
    2440 Betrayed 0
    2440 Glow 0
    2440 Colour 0
    2440 Raise 0
    2440 From 0
    2440 Group 0
    2440 Bruce 0
    2440 Makeup 0
    2440 Make 0
    2440 Studio 0
    2440 Interview 1
    2440 Blackwell 0
    2440 Mr 0
    2440 Hide 0
    2440 Slaughter 0
    2440 Shout 0
    2440 Junior 0
    2440 God 0
    2440 Any 0
    2440 King 2
    2440 Hell 0
    2440 Turn 0
    2440 Tears 0
    2440 No 0
    2440 Picture 0
    2440 Psycho 7
    2440 Carnival 0
    2440 Greatest 0
    2440 Normal 0
    2440 Metal 0
    2440 Heavy 0
    2440 Bad 0
    2440 Sisters 0
    2440 Italo 0
    2440 Nasty 0
    2440 Christine 0
    2440 Cmon 0
    2440 Leila 0
    2440 Detroit 1
    2440 Iwas 0
    2440 We 1
    2440 Scooter 0
    2440 Stadium 0
    2440 Funky 0
    2440 Bros 0
    2440 Radioactive 0
    2440 Zzbros 0
    2440 Loc 0
    2440 Tone 0
    2440 Heaven 5
    2440 Remastered 0
    2440 Star 0
    2440 Bosstones 0
    2440 Cdsingle 1
    2440 Fact 0
    2440 Fun 0
    2440 Keel 0
    2440 Williams 0
    2440 Wendy 0
    2440 Singer 0
    2440 Eric 0
    2440 All 2
    2440 Invasion 0
    2440 Vincent 0
    2440 Vinnie 0
    2440 Cat 0
    2440 Let 0
    2440 Out 0
    2440 Take 0
    2440 The 10
    2440 Loaded 0
    2440 Trouble 0
    2440 Second 0
    2440 Live 0
    2440 Kissin 0
    2440 Superstar 0
    2440 Kiss 4
    2440 Other 0
    2440 Double 0
    2440 Best 0
    2440 Sure 0
    2440 Love 4
    2440 Rock 5
    2440 Dressed 0
    2440 Hotter 0
    2440 German 0
    2440 You 0
    2440 Unplugged 1
    2440 Revenge 0
    2440 Hot 0
    2440 European 0
    2440 Smashes 0
    2440 Crazy 4
    2440 Asylum 0
    2440 Animalize 0
    2440 Lick 4
    2440 Licks 0
    2440 Creatures 1
    2440 Killers 0
    2440 Elder 0
    2440 Music 0
    2440 Union 0
    2440 Unmasked 0
    2440 Italian 0
    2440 Dynasty 0
    2440 Criss 1
    2440 Peter 1
    2440 Stanley 0
    2440 Paul 0
    2440 Simmons 2
    2440 Gene 4
    2440 Frehley 9
    2440 Ace 8
    2440 Destroyer 0
    2440 Canadian 0
    2440 Alive 5
    2440 My 19
  107180 Alternative 12
  107180 Investing 12
  107180 Business 12
  107180 Lists 12
  107180 Directories 12
  107180 Live 22
  107180 Miller 0
  107180 Bill 0
  107180 Email 0
  107180 Rat 0
  107180 Fender 0
  107180 Sugery 0
  107180 Healing 0
  107180 Perform 0
  107180 Slackrevdok 0
  107180 Boston 0
  107180 Box 0
  107180 Revdok 4
  107180 Donation 0
  107180 Offering 0
  107180 Love 0
  107180 Send 0
  107180 Subgenius 0
  107180 Kofsubgenius 0
  107180 Cassette 4
  107180 Two 0
  107180 Cds 0
  107180 Until 0
  107180 Show 0
  107180 Shows 0
  107180 Man 0
  107180 No 0
  107180 Quintaine 0
  107180 Marc 0
  107180 Zia 4
  107180 Grief 0
  107180 Fleshflower 0
  107180 Disrupt 0
  107180 Vocals 0
  107180 Bassvocals 0
  107180 Slack 0
  107180 Drums 12
  107180 With 0
  107180 Ranting 0
  107180 Vocal 0
  107180 Rants 0
  107180 Samples 0
  107180 Guitar 10
  107180 Bass 4
   56189 Marshmel 24
   31027 Conventions 12
   31027 Story 19
   31027 Short 19
   31027 Copyright 0
   31027 Last 0
   31027 If 0
   31027 Homepage 0
   31027 Return 0
   31027 Colorado 0
   31027 Denver 0
   31027 Strategies 0
   31027 Louisiana 0
   31027 Orleans 0
   31027 Faculty 0
   31027 Washington 0
   31027 Spokane 0
   31027 Francisco 0
   31027 San 0
   31027 Interethnic 0
   31027 Sacramento 0
   31027 Warrants 0
   31027 Ireland 0
   31027 Dublin 0
   31027 Arizona 0
   31027 Phoenix 0
   31027 Huntington 0
   31027 Risk 0
   31027 Atrisk 0
   31027 At 0
   31027 Students 0
   31027 Mentoring 0
   31027 Atlanta 0
   31027 Ethnicity 0
   31027 Idaho 0
   31027 Boise 0
   31027 February 0
   31027 Chicago 0
   31027 Presented 11
   31027 Congleton 0
   31027 Australia 0
   31027 Sydney 0
   31027 July 0
   31027 Canada 0
   31027 Montreal 0
   31027 Airheads 0
   31027 May 0
   31027 York 0
   31027 New 0
   31027 Why 0
   31027 Yo 0
   31027 November 4
   31027 Selected 0
   31027 Competitively 0
   31027 October 0
   31027 Business 0
   31027 Choosing 0
   31027 Dolan 0
   31027 John 0
   31027 Office 0
   31027 Chancellor 0
   31027 Beach 0
   31027 Long 0
   31027 Current 0
   31027 Multiple 0
   31027 Koester 0
   31027 Jolene 0
   31027 Invited 0
   31027 Prevention 0
   31027 Sage 0
   31027 Park 0
   31027 Newbury 0
   31027 Eds 0
   31027 Korzenny 0
   31027 Toomey 0
   31027 Tingtoomey 0
   31027 Ting 0
   31027 In 0
   31027 Ghana 0
   31027 Matz 1
   31027 Irene 1
   31027 Netherlands 0
   31027 Amsterdam 0
   31027 Argumentation 14
   31027 Society 0
   31027 Second 0
   31027 Proceedings 0
   31027 The 20
   31027 Gavel 0
   31027 Speaker 0
   31027 Experts 0
   31027 An 0
   31027 Bruschke 0
   31027 Jon 0
   31027 Uncertainty 0
   31027 Reports 0
   31027 Does 0
   31027 Studies 0
   31027 Japan 0
   31027 China 0
   31027 Crosscultural 0
   31027 Cross 0
   31027 Ruiqing 0
   31027 Du 0
   31027 Study 0
   31027 Sueda 0
   31027 Kyoko 0
   31027 Gass 10
   31027 Robert 10
   31027 Congalton 0
   31027 Jeanine 0
   31027 Ju