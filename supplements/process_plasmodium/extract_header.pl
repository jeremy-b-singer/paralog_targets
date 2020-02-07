use Switch 'fallthough';

my @lines = <STDIN>;

my $phase = 0;
my @rec = {};
my $rec_string;
my %recs = ();

foreach my $line(@lines)
{
	switch($phase){
		case 0 {
			if ( $line =~ m/\>\s(\S+)/) # orf id
			{
				$phase = 1;
				$rec[0] = $1;
			}
		}
		case 1 {
			if ( $line =~ m/Length\=(\S+)/ ){
				$rec[scalar(@rec)] = $1;
				$phase = 2;
			}
		}
		case 2 {
			if ( $line =~ m/Score\s\=\s(\S+)/){
				$rec[scalar(@rec)] = $1;
				$line =~ m/Expect\s\=\s(\S+),/;
				$rec[scalar(@rec)] = $1;
				$phase = 3;
			} 
		}
		case 3 {
			if ( $line =~ m/Identities\s\=\s\S+\s\((\S+)\%/){
				$rec[scalar(@rec)] = $1;
				$line =~ m/Positives\s\=\s\S+\s\((\S+)\%/;
				$rec[scalar(@rec)] = $1;
				$line =~ m/Gaps\s\=\s\S+\s\((\S+)\%\)/;
				$rec[scalar(@rec)] = $1;
				$rec_string = join("\t",@rec);
				$recs{$rec_string} = 1;	
				$phase = 0;
				@rec = {};
			}
		}
	}
}

foreach my $record(keys %recs){
	print "$record\n";
}
