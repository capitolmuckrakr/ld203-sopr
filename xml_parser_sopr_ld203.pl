#!/usr/bin/perl -w

# created on 5/27/09 to parse LD-203 contribution reports.

    use XML::XPath;
    
    use XML::XPath::XMLParser;
    
    unless (@ARGV) {
        
        die "No file found.\n";
        
    }

    open (STDERR,">>log_ld203.txt");
    
    #open (OUT,">test_file.txt"); # for debugging
    
    my $datestamp = localtime time;
    
    print STDERR $datestamp,"\n";
    
    foreach (@ARGV) {

    my $getfile = shift;
    
    print STDERR "Parsing $getfile.\n";
    
    my $xp = XML::XPath->new(filename => $getfile );
    
    my $nodeset = $xp->find('//Filing'); # find all filings
    
    my $nodecount; # for debugging
    
    foreach my $node ($nodeset->get_nodelist) {
        
        $nodecount++; #debugging

        my $filing=XML::XPath::XMLParser::as_string($node);
        
            my @rows;
            
            my @row;
            
            my $xfiling = XML::XPath->new(ioref => $filing );            
            
            my ($filing_id,$filingyear,$received,$comments,$filingtype,$period,$registrant,$registrantID,$registrantname,
                $registrantaddress,$registrantcountry,$lobbyist,$lobbyistname,$lobbyistlname);
            
            if ($filing =~ m/ID="(.*?)"/) {
            
            $filing_id=$1;
            
            print STDERR "Parsing filing ",$nodecount," Filing ID: ",$filing_id,"\n";
            
            } else {
                
                warn "No Filing ID found for filing $nodecount!\n";
                
                $filing_id="";
                
            }
            
            if ($filing =~ m/Year="(\d{4})"/) {
            
            $filingyear=$1;
            
            } else {
                
                $filingyear="";
                
            }
            
            if ($filing =~ m/Received="(.*?)"/) {
            
            $received=$1;
                
            } else {
                
                $received="";
                
            }
            
            
            if ($filing =~ m/Comments="(.*?)"/) {
            
            $comments=$1;
                
            } else {
                
                $comments="";
                
            }            
            if ($filing =~ m/Type="(.*?)"/) {
            
            $filingtype=$1;
            
            } else {
                
                $filingtype="";
                
            }
            
            if ($filing =~ m/Period="(.*?)"/) {
            
            $period=$1;
            
            } else {
                
                $period="";
                
            }            
            
            $registrant = parse_field_scalar($xfiling,'//Registrant'); # find Registrant
            
            if ($registrant =~ m@RegistrantID="(\d+)"@) {
                
                $registrantID=$1;
                
            } else {
                
                $registrantID="";
                
            }
            
            if ($registrant =~ m@RegistrantName="(.*?)"@) {
                
                $registrantname=$1;
                
            } else {
                
                $registrantname="";
                
            }      
            
            if ($registrant =~ m@Address="(.*?)"@) {
                
                $registrantaddress=$1;
                
            } else {
                
                $registrantaddress="";
                
            }
            
            if ($registrant =~ m@RegistrantCountry="(.*?)"@) {
                
                $registrantcountry=$1;
                
            } else {
                
                $registrantcountry="";
                
            }
            
            $lobbyist = parse_field_scalar($xfiling,'//Lobbyist'); # find Lobbyist
            
            if ($lobbyist =~ m@LobbyistName="(.*?)"@) {
                
                $lobbyistname=$1;
                
            } else {
                
                $lobbyistname="";
                
            }
	    
	    		
	    if ($lobbyistname =~ m@,@) {
                
		$lobbyistlname = substr($lobbyistname,0,index($lobbyistname,','));

	    } else {
                
		$lobbyistlname="";
                
		   } 
	    
	    
	    
            @row = ($filing_id,$filingyear,$received,$comments,$filingtype,$period,$registrantID,$registrantname,$registrantaddress, #elements 0-8
                    $registrantcountry,$lobbyistname,$lobbyistlname, #elements 9-11
                    "","","","","","", #contrib, elements 12-17
                    $getfile); #filename element 18
            
            push @rows,\@row;
            
            #print OUT join("|",@row),"\n"; # for debugging
            
            my $contrib_ref = parse_field_array($xfiling,'//Contributions','//Contribution'); # find each Contribution
            
            if ($contrib_ref) {
                
                foreach my $contrib_xml (@{$contrib_ref}) {
                    
                    my $contrib = clean_fields(make_string($contrib_xml));
                   
                    my @row1 = @row;
                    
                    my ($contributor_name,$contribution_type,$payee,$honoree,$amount,$contrib_date);
                    
                    if ($contrib =~ m@Contributor="(.*?)"@s) {
                        
                        $contributor_name = $1;
                        
                    } else {
                        
                        $contributor_name="";
                        
                    }
                    
                    if ($contrib =~ m@ContributionType="(.*?)"@s) {
                        
                        $contribution_type = $1;
                        
                    } else {
                        
                        $contribution_type="";
                        
                    }
                    
                    if ($contrib =~ m@Payee="(.*?)"@s) {
                        
                        $payee = $1;
                        
                    } else {
                        
                        $payee="";
                        
                    }
                    
                    if ($contrib =~ m@Honoree="(.*?)"@s) {
                        
                        $honoree = $1;
                        
                    } else {
                        
                        $honoree="";
                        
                    }
                    
                    if ($contrib =~ m@Amount="(.*?)"@s) {
                        
                        $amount = $1;
                        
                    } else {
                        
                        $amount="";
                        
                    }
                    
                    if ($contrib =~ m@ContributionDate="(.*?)"@s) {
                        
                        $contrib_date = $1;
                        
                    } else {
                        
                        $contrib_date="";
                        
                    }                    
		    
                    ($row1[12],$row1[13],$row1[14],$row1[15],$row1[16],$row1[17]) = ($contributor_name,$contribution_type,$payee,$honoree,$amount,$contrib_date);
                    
                    push @rows,\@row1;
                 
                } 
                
            } 
	    
            foreach my $row (@rows) {
                
                print join("|",$$row[0],$$row[1],$$row[2],$$row[3],$$row[4],$$row[5],$$row[6],$$row[7],$$row[8],
                $$row[9],$$row[10],$$row[11],$$row[12],$$row[13],$$row[14],$$row[15],$$row[16],$$row[17],$$row[18]),"\n";
                
            }
        
    }
    
    }
    
#*/|\**/|\*/|\**/|\*/|\**/|\*/|\**/|\*/|\**/|\*_subroutines are here_*/|\**/|\*/|\**/|\*/|\**/|\*/|\**/|\*/|\**/|\*#

 sub parse_field_scalar {
        
            my $xml = shift;
            
            my $search_string=shift;
            
            my $nodeset2 = $xml->find($search_string); # find pattern
            
            if ($nodeset2) {
                
                return clean_fields(make_string($nodeset2->get_nodelist));
               
            } else {
                
                return "BLANK";
                
            }
        
    }
    
    sub parse_field_array {
        
            my $xml = shift;
            
            my $search_string=shift;
            
            my $search_element=shift;
            
            my $nodeset2 = $xml->find($search_string); # find pattern
            
            if ($nodeset2) {
            
            my $node2i = XML::XPath::XMLParser::as_string($nodeset2->get_nodelist);
            
            my $xml_element = XML::XPath->new(ioref => $node2i );
            
            my $nodeset3 = $xml_element->find($search_element); # find each element
            
            my @node3 = $nodeset3->get_nodelist;
            
            return \@node3;
            
            } else {
                
                return "BLANK NODE";
                
            }
        
        
    }

    sub make_string {
        
        $string1=shift;
        
        $string2=XML::XPath::XMLParser::as_string($string1);
        
        return $string2;
        
    }
    
    sub clean_fields {
        
        my $string = shift;
        
        $string =~ s/\n//gs;
        
        $string =~ s/&amp;/&/gs;
        
        $string;
        
    }
    