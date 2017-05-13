# Loading OPTAB from OPTAB.txt
optab=Hash.new
file=File.open("OPTAB.txt")
while line=file.gets
		line=line.split
		optab[line.delete_at(1)]=line
		end
file.close

# Loading REGCODE from REGCODE.txt generated during 'pass 1'
regcode=Hash.new
file=File.open("REGCODE.txt")
while line=file.gets
		line=line.split
		regcode[line[0]]=line[1]
		end
file.close

# Loading SYMTAB from SYMTAB.txt generated during 'pass 1'
symtab=Hash.new
file=File.open("SYMTAB.txt")
while line=file.gets
		line=line.split
		symtab[line[0]]=line[1]
		end
file.close

intermediate=File.open("intermediate_xe.txt")
start_addr=0
while line_org=intermediate.gets
	line=line_org.split
	if line[1]=='START'
		break
	end
end
base=nil
while line_org=intermediate.gets

	line=line_org.split

	case line[0]
	when 'END'
		# puts line_org
		break
	when 'BASE'
		base=symtab[line[1]]
		next
	when 'LTORG','ORG','USE','CSECT'
		puts line_org
		next
	end
	
	last=line[-1]
	slast=line[-2]

	if optab[last]
		case optab[last][1]
		when '1'
			puts optab[last][0]
		when '2'
			puts optab[last][0]+"00"
		else
			puts (((optab[last][0]).to_i(16)+3).to_s(16)).rjust(2,'0')+"0000"	
		end
	elsif last.start_with?("+")
		puts (((optab[last][0]).to_i(16)+3).to_s(16)).rjust(2,'0')+"000000"
	else
		if optab[slast]
			# Format-2 Logic
			if optab[slast][1]=='2'
				print optab[slast][0]
				operand=last.split(",").map(&:strip)
				print regcode[operand[0]]
				if operand.length==1
					puts "0"
				else
					puts regcode[operand[1]]
				end

			# Format-3 Logic
			elsif optab[slast][1]=='3/4'	
				if symtab[last]
					# LOOK HERE
					ta=symtab[last]
					pc=((line[0].to_i(16)+3).to_s(16))
					disp=(ta.to_i(16)-pc.to_i(16)).to_s(16)
					# p disp
					if disp.to_i(16) > "FFF".to_i(16)
						disp=((ta.to_i(16)-base.to_i(16)).to_s(16))
						puts (((optab[slast][0]).to_i(16)+3).to_s(16)).rjust(2,'0')+"4"+disp.rjust(3,'0')
					else
						puts (((optab[slast][0]).to_i(16)+3).to_s(16)).rjust(2,'0')+"2"+disp.rjust(3,'0')
					end
				elsif last.start_with?("@")
					if symtab[last.slice(1..-1)]
						ta=symtab[last.slice(1..-1)]
						pc=((line[0].to_i(16)+3).to_s(16))
						disp=(ta.to_i(16)-pc.to_i(16)).to_s(16)
						if disp.to_i(16) > "FFF".to_i(16)
							disp=((ta.to_i(16)-base.to_i(16)).to_s(16))
							puts (((optab[slast]).to_i(16)+2).to_s(16)).rjust(2,'0')+"4"+disp.rjust(3,'0')
						else
							puts (((optab[slast][0]).to_i(16)+2).to_s(16)).rjust(2,'0')+"2"+disp.rjust(3,'0')
						end
					else
						puts (((optab[slast][0]).to_i(16)+2).to_s(16)).rjust(2,'0')+"0"+last.slice(1..-1).to_i(16).to_s.rjust(3,'0')
					end
				elsif last.start_with?("#")
					if symtab[last.slice(1..-1)]
						ta=symtab[last.slice(1..-1)]
						pc=((line[0].to_i(16)+3).to_s(16))
						disp=(ta.to_i(16)-pc.to_i(16)).to_s(16)
						if disp.to_i(16) > "FFF".to_i(16)
							disp=((ta.to_i(16)-base.to_i(16)).to_s(16))
							puts (((optab[slast][0]).to_i(16)+1).to_s(16)).rjust(2,'0')+"4"+disp.rjust(3,'0')
						else
							puts (((optab[slast][0]).to_i(16)+1).to_s(16)).rjust(2,'0')+"2"+disp.rjust(3,'0')
						end
					else
						puts (((optab[slast][0]).to_i(16)+1).to_s(16)).rjust(2,'0')+"0"+last.slice(1..-1).to_i(16).to_s.rjust(3,'0')
					end
				elsif last.end_with?(",X")
					if symtab[last.slice(0..-3)]
						ta=symtab[last.slice(0..-3)]
						pc=((line[0].to_i(16)+3).to_s(16))
						disp=(ta.to_i(16)-pc.to_i(16)).to_s(16)
						if disp.to_i(16) > "FFF".to_i(16)
							disp=((ta.to_i(16)-base.to_i(16)).to_s(16))
							puts (((optab[slast][0]).to_i(16)+1).to_s(16)).rjust(2,'0')+"c"+disp.rjust(3,'0')
						else
							puts (((optab[slast][0]).to_i(16)+1).to_s(16)).rjust(2,'0')+"a"+disp.rjust(3,'0')
						end
					else
						puts (((optab[slast][0]).to_i(16)+1).to_s(16))+"8"+last.slice(0..-3).to_i(16).to_s.rjust(3,'0')
					end

				else
					puts (((optab[slast][0]).to_i(16)+3).to_s(16)).rjust(2,'0')+"0"+last.slice(-3..-1).rjust(3,'0')
				end	
			end

		# Format-4 Logic
		elsif slast.start_with?("+")
			if symtab[last]
				puts (((optab[slast.slice(1..-1)][0]).to_i(16)+3).to_s(16)).rjust(2,'0')+"1"+symtab[last].rjust(5,'0')
			elsif last.start_with?("@")
				puts (((optab[slast.slice(1..-1)][0]).to_i(16)+2).to_s(16)).rjust(2,'0')+"1"+symtab[last].rjust(5,'0')
			elsif last.start_with?("#")
				if symtab[last.slice(1..-1)]
					puts (((optab[slast.slice(1..-1)][0]).to_i(16)+1).to_s(16)).rjust(2,'0')+"1"+symtab[last.slice(1..-1)].rjust(5,'0')
				else
					puts (((optab[slast.slice(1..-1)][0]).to_i(16)+1).to_s(16)).rjust(2,'0')+"1"+last.slice(1..-1).to_i.to_s(16).rjust(5,'0')
				end
			elsif last.end_with?(",X")
				puts (((optab[slast.slice(1..-1)][0]).to_i(16)+3).to_s(16)).rjust(2,'0')+"9"+symtab[last.slice(0..-3)].rjust(5,'0')
			end	

		elsif slast=='WORD'
			puts last.to_i(16).to_s.rjust(6,'0')

		elsif slast=='RESW'
			# Do Nothing

		elsif slast=='RESB'
			# Do Nothing

		elsif slast=='BYTE'
			case last[0]
			when 'C'
				puts last.slice(2..-2).unpack('H*')[0]
			when 'X'
				puts last.slice(2..-2)
			end
		end		
	end
	
end
intermediate.close
