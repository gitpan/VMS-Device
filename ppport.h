   #ifndef _P_P_PORTABILITY_H_  #define _P_P_PORTABILITY_H_   / /* Perl/Pollution/Portability Version 1.0007 */   D /* Copyright (C) 1999, Kenneth Albanowski. This code may be used and@    distributed under the same license as any version of Perl. */     I /* For the latest version of this code, please retreive the Devel::PPPort H    module from CPAN, contact the author at <kjahds@kjahds.com>, or check     with the Perl maintainers. */     H /* If you needed to customize this file for your project, please mention9    your changes, and visible alter the version number. */      /*E    In order for a Perl extension module to be as portable as possible L    across differing versions of Perl itself, certain steps need to be taken.K    Including this header is the first major one, then using dTHR is all the D    appropriate places and using a PL_ prefix to refer to global Perl    variables is the second.  */    E /* If you use one of a few functions that were not present in earlier I    versions of Perl, please add a define before the inclusion of ppport.h H    for a static include, or use the GLOBAL request in a single module toD    produce a global definition that can be referenced from the other    modules.      ?    Function:            Static define:           Extern define: H    newCONSTSUB()        NEED_newCONSTSUB         NEED_newCONSTSUB_GLOBAL   */     H /* To verify whether ppport.h is needed for your module, and whether anyL    special defines should be used, ppport.h can be run through Perl to check     your source code. Simply say:     /    	perl -x ppport.h *.c *.h *.xs foo/*.c [etc]      I    The result will be a list of patches suggesting changes that should at L    least be acceptable, if not necessarily the most efficient solution, or aJ    fix for all possible problems. It won't catch where dTHR is needed, andG    doesn't attempt to account for global macro or function definitions, "    nested includes, typemaps, etc.     H    In order to test for the need of dTHR, please try your module under a9    recent version of Perl that has threading compiled-in.     */       /* #!/usr/bin/perl  @ARGV = ("*.xs") if !@ARGV; 1 %badmacros = %funcs = %macros = (); $replace = 0;  foreach (<DATA>) {& 	$funcs{$1} = 1 if /Provide:\s+(\S+)/;4 	$macros{$1} = 1 if /^#\s*define\s+([a-zA-Z0-9_]+)/;% 	$replace = $1 if /Replace:\s+(\d+)/; X 	$badmacros{$2}=$1 if $replace and /^#\s*define\s+([a-zA-Z0-9_]+).*?\s+([a-zA-Z0-9_]+)/;1 	$badmacros{$1}=$2 if /Replace (\S+) with (\S+)/;  } ) foreach $filename (map(glob($_),@ARGV)) { " 	unless (open(IN, "<$filename")) {) 		warn "Unable to read from $file: $!\n";  		next;  	}! 	print "Scanning $filename...\n"; / 	$c = ""; while (<IN>) { $c .= $_; } close(IN); 1 	$need_include = 0; %add_func = (); $changes = 0; . 	$has_include = ($c =~ /#.*include.*ppport/m);   	foreach $func (keys %funcs) {5 		if ($c =~ /#.*define.*\bNEED_$func(_GLOBAL)?\b/m) {  			if ($c !~ /\b$func\b/m) {E 				print "If $func isn't needed, you don't need to request it.\n" if > 				$changes += ($c =~ s/^.*#.*define.*\bNEED_$func\b.*\n//m); 			} else {  				print "Uses $func\n";  				$need_include = 1; 			}
 		} else { 			if ($c =~ /\b$func\b/m) { 				$add_func{$func} =1 ;  				print "Uses $func\n";  				$need_include = 1; 			} 		}  	}   	if (not $need_include) { ! 		foreach $macro (keys %macros) {  			if ($c =~ /\b$macro\b/m) {  				print "Uses $macro\n"; 				$need_include = 1; 			} 		}  	}  & 	foreach $badmacro (keys %badmacros) { 		if ($c =~ /\b$badmacro\b/m) { @ 			$changes += ($c =~ s/\b$badmacro\b/$badmacros{$badmacro}/gm);? 			print "Uses $badmacros{$badmacro} (instead of $badmacro)\n";  			$need_include = 1;  		}  	} 	 ? 	if (scalar(keys %add_func) or $need_include != $has_include) {  		if (!$has_include) {A 			$inc = join('',map("#define NEED_$_\n", sort keys %add_func)). $ 			       "#include \"ppport.h\"\n";> 			$c = "$inc$c" unless $c =~ s/#.*include.*XSUB.*\n/$&$inc/m; 		} elsif (keys %add_func) {A 			$inc = join('',map("#define NEED_$_\n", sort keys %add_func)); B 			$c = "$inc$c" unless $c =~ s/^.*#.*include.*ppport.*$/$inc$&/m; 		}  		if (!$need_include) { , 			print "Doesn't seem to need ppport.h.\n";( 			$c =~ s/^.*#.*include.*ppport.*\n//m; 		}  		$changes++;  	} 	  	if ($changes) {  		open(OUT,">/tmp/ppport.h.$$"); 		print OUT $c;  		close(OUT); 4 		open(DIFF, "diff -u $filename /tmp/ppport.h.$$|");K 		while (<DIFF>) { s!/tmp/ppport\.h\.$$!$filename.patched!; print STDOUT; }  		close(DIFF); 		unlink("/tmp/ppport.h.$$"); 	 	} else {  		print "Looks OK\n";  	} }  __DATA__ */   #ifndef PERL_REVISION $ #   ifndef __PATCHLEVEL_H_INCLUDED__ #       include "patchlevel.h"	 #   endif  #   ifndef PERL_REVISION #	define PERL_REVISION	(5)         /* Replace: 1 */& #       define PERL_VERSION	PATCHLEVEL) #       define PERL_SUBVERSION	SUBVERSION 7         /* Replace PERL_PATCHLEVEL with PERL_VERSION */          /* Replace: 0 */	 #   endif  #endif  c #define PERL_BCDVERSION ((PERL_REVISION * 0x1000000L) + (PERL_VERSION * 0x1000L) + PERL_SUBVERSION)    #ifndef ERRSV % #	define ERRSV perl_get_sv("@",FALSE)  #endif  I #if (PERL_VERSION < 4) || ((PERL_VERSION == 4) && (PERL_SUBVERSION <= 5))  /* Replace: 1 */ #	define PL_sv_undef	sv_undef  #	define PL_sv_yes	sv_yes  #	define PL_sv_no		sv_no #	define PL_na		na #	define PL_stdingv	stdingv  #	define PL_hints		hints #	define PL_curcop	curcop  #	define PL_curstash	curstash  #	define PL_copline	copline  #	define PL_Sv		Sv /* Replace: 0 */ #endif   #ifndef dTHR #  ifdef WIN32' #	define dTHR extern int Perl___notused  #  else  #	define dTHR extern int errno #  endif #endif   #ifndef boolSV1 #	define boolSV(b) ((b) ? &PL_sv_yes : &PL_sv_no)  #endif   #ifndef gv_stashpvn 9 #	define gv_stashpvn(str,len,flags) gv_stashpv(str,flags)  #endif   #ifndef newSVpvnO #	define newSVpvn(data,len) ((len) ? newSVpv ((data), (len)) : newSVpv ("", 0))  #endif   #ifndef newRV_inc  /* Replace: 1 */  #	define newRV_inc(sv) newRV(sv) /* Replace: 0 */ #endif   #ifndef newRV_noinc  #  ifdef __GNUC__ + #    define newRV_noinc(sv)               \ +       ({                                  \ +           SV *nsv = (SV*)newRV(sv);       \ +           SvREFCNT_dec(sv);               \ +           nsv;                            \        }) #  else 4 #    if defined(CRIPPLED_CC) || defined(USE_THREADS)! static SV * newRV_noinc (SV * sv)  { *           SV *nsv = (SV*)newRV(sv);       *           SvREFCNT_dec(sv);               *           return nsv;                      } 	 #    else " #      define newRV_noinc(sv)    \=         ((PL_Sv=(SV*)newRV(sv), SvREFCNT_dec(sv), (SV*)PL_Sv) 
 #    endif #  endif #endif   /* Provide: newCONSTSUB */  B /* newCONSTSUB from IO.xs is in the core starting with 5.004_63 */I #if (PERL_VERSION < 4) || ((PERL_VERSION == 4) && (PERL_SUBVERSION < 63))    #if defined(NEED_newCONSTSUB)  static #else = extern void newCONSTSUB _((HV * stash, char * name, SV *sv));  #endif  A #if defined(NEED_newCONSTSUB) || defined(NEED_newCONSTSUB_GLOBAL)  void newCONSTSUB(stash,name,sv)
 HV *stash; char *name;  SV *sv;  {  	U32 oldhints = PL_hints; * 	HV *old_cop_stash = PL_curcop->cop_stash;  	HV *old_curstash = PL_curstash;& 	line_t oldline = PL_curcop->cop_line;" 	PL_curcop->cop_line = PL_copline;   	PL_hints &= ~HINT_BLOCK_SCOPE;  	if (stash) - 		PL_curstash = PL_curcop->cop_stash = stash;    	newSUB(  I #if (PERL_VERSION < 3) || ((PERL_VERSION == 3) && (PERL_SUBVERSION < 22))       /* before 5.003_22 */ 		start_subparse(),  #else 4 #  if (PERL_VERSION == 3) && (PERL_SUBVERSION == 22)      /* 5.003_22 */       		start_subparse(0),  #  else       /* 5.003_23  onwards */       		start_subparse(FALSE, 0), #  endif #endif  ( 		newSVOP(OP_CONST, 0, newSVpv(name,0)),G 		newSVOP(OP_CONST, 0, &PL_sv_no),   /* SvPV(&PL_sv_no) == "" -- GMB */ 1 		newSTATEOP(0, Nullch, newSVOP(OP_CONST, 0, sv))  	);    	PL_hints = oldhints; & 	PL_curcop->cop_stash = old_cop_stash; 	PL_curstash = old_curstash; 	PL_curcop->cop_line = oldline;  }  #endif   #endif /* newCONSTSUB */      #endif /* _P_P_PORTABILITY_H_ */                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                794 King 0
   48794 Film 0
   48794 Godzilla 0
   48794 German 0
   48794 Get 0
   48794 Berlin 0
   48794 Never 0
   48794 Humble 0
   48794 Machkov 0
   48794 Vladimir 0
   48794 Dixon 0
   48794 Thief 0
   48794 Conmen 0
   48794 Jr 0
   48794 Downey 0
   48794 Duvall 0
   48794 Davidtz 0
   48794 Embeth 0
   48794 Branagh 0
   48794 Kenneth 0
   48794 Georgia 0
   48794 Savannah 0
   48794 Gingerbread 0
   48794 Grisham 0
   48794 Altman 0
   48794 Director 0
   48794 Full 0
   48794 Funeral 0
   48794 Fleet 0
   48794 Kemp 0
   48794 Dawson 0
   48794 Monk 0
   48794 Waller 0
   48794 Dying 0
   48794 Lay 0
   48794 Night 0
   48794 Waterloo 0
   48794 Vic 0
   48794 Anyone 0
   48794 Alfie 0
   48794 Caine 0
   48794 Michael 0
   48794 Quarcoo 0
   48794 Ernestina 0
   48794 Chandra 0
   48794 Nitin 0
   48794 Grewal 0
   48794 Russia 0
   48794 Shani 0
   48794 Asian 0
   48794 Tahiti 0
   48794 Seas 0
   48794 South 0
   48794 Ellen 0
   48794 Heche 0
   48794 Nights 0
   48794 Seven 0
   48794 Days 0
   48794 Six 0
   48794 Ford 0
   48794 Harrison 0
   48794 Lead 0
   48794 Courtney 0
   48794 Cobain 0
   48794 Kurt 0
   48794 Nirvana 0
   48794 Hollywood 0
   48794 Fleiss 0
   48794 Broomfield 0
   48794 Could 0
   48794 Tucci 0
   48794 Hope 0
   48794 Daytrippers 0
   48794 York 0
   48794 Allen 0
   48794 Woody 0
   48794 Adair 0
   48794 Gilbert 0
   48794 Maybe 0
   48794 Priestley 0
   48794 Jason 0
   48794 Island 0
   48794 Death 0
   48794 Consequently 0
   48794 Miss 0
   48794 Rudd 0
   48794 Affection 0
   48794 Object 0
   48794 Aniston 0
   48794 Jennifer 0
   48794 Roffman 0
   48794 Howard 0
   48794 Videos 0
   48794 White 0
   48794 Mesmerised 0
   48794 Lucille 0
   48794 Isabel 0
   48794 Laurel 0
   48794 Campbell 0
   48794 Uswide 0
   48794 Anne 0
   48794 Letty 0
   48794 Fritchley 0
   48794 Alma 0
   48794 Chicken 0
   48794 Sappho 0
   48794 Warner 0
   48794 Townsend 0
   48794 Sense 0
   48794 Sylvia 0
   48794 Dickinson 0
   48794 Emily 0
   48794 Spraggs 0
   48794 Gillian 0
   48794 Senses 0
   48794 Shook 0
   48794 Love 0
   48794 Dictionaries 0
   48794 Zymase 0
   48794 Clugston 0
   48794 Science 0
   48794 Dictionary 0
   48794 New 0
   48794 Chatterley 0
   48794 Lady 0
   48794 Enlightenment 0
   48794 Shakespeare 0
   48794 Ages 0
   48794 Middle 0
   48794 Saxon 0
   48794 Anglosaxon 0
   48794 Anglo 0
   48794 Penguin 0
   48794 Hughes 0
   48794 Geoffrey 0
   48794 Swearing 0
   48794 Under 0
   48794 Painting 0
   48794 Production 0
   48794 Eventually 0
   48794 Grainger 0
   48794 Samuel 0
   48794 Oxford 0
   48794 Cardell 0
   48794 Higgins 0
   48794 Terrence 0
   48794 Guidelines 0
   48794 Safer 0
   48794 Month 0
   48794 Monty 0
   48794 Book 0
   48794 Branson 0
   48794 Publishing 0
   48794 Friends 0
   48794 Virgin 0
   48794 Rupert 0
   48794 Country 0
   48794 Customs 0
   48794 Milne 0
   48794 Justin 0
   48794 Almost 0
   48794 Gmunder 0
   48794 Bruno 0
   48794 Lalli 0
   48794 Photographs 0
   48794 Heather 0
   48794 Iran 0
   48794 Press 0
   48794 Prowler 0
   48794 Doll 0
   48794 Dolls 0
   48794 How 0
   48794 Written 0
   48794 Rather 0
   48794 Since 0
   48794 Feed 0
   48794 Feel 0
   48794 Guess 0
   48794 Services 0
   48794 Boy 0
   48794 Daydreemin 0
   48794 Why 0
   48794 Coast 0
   48794 Schwimmer 0
   48794 Guru 0
   48794 West 0
   48794 Payne 0
   48794 Drew 0
   48794 Howre 0
   48794 Yes 0
   48794 Slowly 0
   48794 Afterwards 0
   48794 Because 0
   48794 Santiago 0
   48794 Hand 0
   48794 Bringing 0
   48794 Their 0
   48794 My 0
   48794 Walker 0
   48794 Martin 0
   48794 Nor 0
   48794 Period 0
   48794 Back 0
   48794 Servant 0
   48794 Civil 0
   48794 Practising 0
   48794 Macgregor 0
   48794 Euan 0
   48794 Straight 0
   48794 Heterosexuals 0
   48794 Useful 0
   48794 Definitely 0
   48794 Weighted 0
   48794 Hardly 0
   48794 Mother 0
   48794 Assistance 0
   48794 Pitt 0
   48794 Brad 0
   48794 Minogue 0
   48794 Kylie 0
   48794 Manning 0
   48794 Bernard 0
   48794 Who 0
   48794 Huong 0
   48794 Hong 0
   48794 Tien 0
   48794 Cao 0
   48794 Vinh 0
   48794 Party 0
   48794 Communist 0
   48794 Legislators 0
   48794 Presse 0
   48794 Francepresse 0
   48794 Vietnam 0
   48794 Christianity 0
   48794 Vatican 0
   48794 Scores 0
   48794 Gaypride 0
   48794 Finland 0
   48794 Following 0
   48794 Recognition 0
   48794 Jospin 0
   48794 Lionel 0
   48794 Minister 0
   48794 France 0
   48794 Lille 0
   48794 May 0
   48794 Service 0
   48794 Municipal 0
   48794 Hivpositivity 0
   48794 Australian 0
   48794 For 0
   48794 Brother 0
   48794 Big 0
   48794 Sorry 0
   48794 Prime 0
   48794 Prior 0
   48794 Interactive 0
   48794 Live 0
   48794 Travel 0
   48794 Mcclelland 0
   48794 Doug 0
   48794 Total 0
   48794 Chisel 0
   48794 Once 0
   48794 Kiosque 0
   48794 Canada 0
   48794 Online 0
   48794 America 0
   48794 Agence 0
   48794 Animals 0
   48794 April 0
   48794 Kim 0
   48794 Mugabe 0
   48794 Robert 0
   48794 Current 0
   48794 Banana 0
   48794 Canaan 0
   48794 Vuma 0
   48794 Siphephule 0
   48794 Goddard 0
   48794 Zimbabwe 0
   48794 Lesbians 0
   48794 Girls 0
   48794 Wockner 0
   48794 Duyen 0
   48794 Rex 0
   48794 Derek 0
   48794 Attitudes 0
   48794 Arquette 0
   48794 Parliament 0
   48794 Muirhouse 0
   48794 Easterhouse 0
   48794 Holyrood 0
   48794 Otherwise 0
   48794 Articles 0
   48794 Keep 0
   48794 Expect 0
   48794 Wimpey 0
   48794 English 0
   48794 Guardian 0
   48794 Uni 0
   48794 Dont 0
   48794 You 0
   48794 Pause 0
   48794 Effeminacy 0
   48794 Streisand 0
   48794 Hudson 0
   48794 Rock 0
   48794 Diana 0
   48794 Day 0
   48794 Doris 0
   48794 Wilde 0
   48794 Will 0
   48794 Oscar 0
   48794 Garland 0
   48794 Hurt 0
   48794 Our 0
   48794 Likewise 0
   48794 Thirdly 0
   48794 Radio 0
   48794 Secondly 0
   48794 Sillars 0
   48794 Jim 0
   48794 Left 0
   48794 Old 0
   48794 Firstly 0
   48794 Consent 0
   48794 Age 0
   48794 To 0
   48794 Snickers 0
   48794 Or 0
   48794 Precious 0
   48794 Airport 0
   48794 Marys 0
   48794 Musclemarys 0
   48794 Darkness 0
   48794 Prince 0
   48794 Hall 0
   48794 Stanley 0
   48794 Professor 0
   48794 Interestingly 0
   48794 Observation 0
   48794 Mass 0
   48794 Secret 0
   48794 Simpsons 0
   48794 Blackpool 0
   48794 Regency 0
   48794 Brighton 0
   48794 Of 0
   48794 Ganatra 0
   48794 Victorians 0
   48794 Whitsun 0
   48794 Wakes 0
   48794 People 0
   48794 University 0
   48794 Islander 0
   48794 Fishman 0
   48794 Friday 0
   48794 Robbie 0
   48794 Fair 0
   48794 Inn 0
   48794 Shell 0
   48794 Brenda 0
   48794 Rover 0
   48794 Land 0
   48794 Speaking 0
   48794 Perhaps 0
   48794 Ardeer 0
   48794 Arran 0
   48794 Lagg 0
   48794 Shore 0
   48794 Apart 0
   48794 Garnock 0
   48794 Bru 0
   48794 Irn 0
   48794 Serpentine 0
   48794 Two 0
   48794 Constabulary 0
   48794 Inspector 0
   48794 Dunning 0
   48794 Leonard 0
   48794 Sir 0
   48794 Workers 0
   48794 Women 0
   48794 Union 0
   48794 Before 0
   48794 Movement 0
   48794 Hygiene 0
   48794 Purity 0
   48794 Vigilance 0
   48794 National 0
   48794 While 0
   48794 Seine 0
   48794 Asnieres 0
   48794 Bathing 0
   48794 Reality 0
   48794 Seurat 0
   48794 Tuke 0
   48794 Henry 0
   48794 Ayrshire 0
   48794 Sun 0
   48794 Gailes 0
   48794 Good 0
   48794 Mention 0
   48794 Stevenston 0
   48794 Irvine 0
   48794 Lang 0
   48794 Many 0
   48794 During 0
   48794 Scheveningen 0
   48794 Zee 0
   48794 Aan 0
   48794 Zandvoort 0
   48794 Neither 0
   48794 British 0
   48794 Families 0
   48794 Within 0
   48794 Utrecht 0
   48794 Outside 0
  