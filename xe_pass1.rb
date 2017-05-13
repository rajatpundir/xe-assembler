# This is 'pass-1' of 'two-pass' SIC/XE Assembler written in ruby 2.3.1.
optab=Hash.new
file=File.open("OPTAB.txt")
while line=file.gets
		line=line.split
		optab[line.delete_at(1)]=line
		end
file.close

# Building 'SYMTAB' from source code and writing intermediate file
symtab=Hash.new
start_check=false
locctr=start_addr=0
source=File.open("source_xe.txt")
intermediate=File.open("intermediate_xe.txt", "w")
while line_org=source.gets
	line=line_org.split
	if line[1]=='START'
		locctr=start_addr=line[2]
		intermediate.puts("\t\t"+line_org)
		start_check=true
		break;
	end
end
if start_check
	while line_org=source.gets
		line=line_org.split
		first=line[0]
		second=line[1]
		third=line[2]
		case first
		when 'END'
			intermediate.puts(line_org)
			break
		when 'BASE','LTORG','ORG','USE','CSECT'
			intermediate.puts("\t"+line_org)
			next
		end
		intermediate.puts(locctr.rjust(4,"0")+"\t"+line_org)
		if optab[first]
			if optab[first][1]=="3/4"
			locctr=((locctr.to_i(16)+3).to_s(16)).to_s
			else
			locctr=((locctr.to_i(16)+optab[first][1].to_i).to_s(16)).to_s
			end
		elsif first.start_with?("+")
			locctr=((locctr.to_i(16)+4).to_s(16)).to_s
		elsif first=='WORD'
			locctr=((locctr.to_i(16)+3).to_s(16)).to_s
		elsif first=='RESW'
			locctr=((locctr.to_i(16)+3*second.to_i).to_s(16)).to_s
		elsif first=='RESB'
			locctr=((locctr.to_i(16)+second.to_i).to_s(16)).to_s
		elsif first=='BYTE'
			if second[0]=='C'
				locctr=((locctr.to_i(16)+second.length-3).to_s(16)).to_s
			elsif second[0]=='X'
				locctr=((locctr.to_i(16)+(second.length-3)/2).to_s(16)).to_s
			end	
		elsif symtab[first]
			puts 'duplicate symbol error'
		else
			symtab[first]=locctr.rjust(4,"0")
			if second=='WORD'
				locctr=((locctr.to_i(16)+3).to_s(16)).to_s
			elsif second=='RESW'
				locctr=((locctr.to_i(16)+3*third.to_i).to_s(16)).to_s
			elsif second=='RESB'
				locctr=((locctr.to_i(16)+third.to_i).to_s(16)).to_s
			elsif second=='BYTE'
				if third[0]=='C'
					locctr=((locctr.to_i(16)+third.length-3).to_s(16)).to_s
				elsif third[0]=='X'
					locctr=((locctr.to_i(16)+(third.length-3)/2).to_s(16)).to_s
				end	
			else
				if second.start_with?("+")
				locctr=((locctr.to_i(16)+4).to_s(16)).to_s
				elsif optab[second][1]=="3/4"
				locctr=((locctr.to_i(16)+3).to_s(16)).to_s
				else
				locctr=((locctr.to_i(16)+optab[second][1].to_i).to_s(16)).to_s
				end
			end
		end
	end
end

# Writing end value of 'LOCCTR'
LOCCTR=File.open("LOCCTR.txt", "w")
LOCCTR.puts("LOCCTR\t"+locctr)
LOCCTR.close

# Writing 'SYMTAB'
sym_file=File.open("SYMTAB.txt", "w")
symtab.each {|k,v| sym_file.puts("#{k}\t #{v}")}
sym_file.close