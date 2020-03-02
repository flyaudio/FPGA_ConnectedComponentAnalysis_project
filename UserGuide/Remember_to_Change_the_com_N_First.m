
clc;clear all;


%名 称：Matlab串口-Lab1  
%描 述：串口读，并写入txt文件中  
s=serial('com12','BaudRate',14400);  
s.BytesAvailableFcnMode='byte';  % 串口设置  
s.InputBufferSize=4096;  
s.OutputBufferSize=1024;  
s.BytesAvailableFcnCount=100;  
s.ReadAsyncMode='continuous';  
s.Terminator='CR';  
fopen(s);                  %打开串口  
head_byte_1 = 0;
head_byte_2 = 0;
% for i=1:39
while(1)
	[out count msg]=fread(s,1,'uint8');    
	if(~isempty(msg) == 1 )
		fprintf('error:The specified amount of data was not returned within the Timeout period.');
		break;
	end
	
   
	if(out == hex2dec('55'))
		fprintf('55  '); 
		head_byte_1 = 1;
		head_byte_2 = 0;
	elseif(out == hex2dec('AA') && head_byte_1 == 1)
		fprintf('AA  '); 
		% fprintf('\n'); 
		head_byte_1 = 0;
		head_byte_2 = 1;
	else	
		head_byte_1 = 0;
		head_byte_2 = 0;
		
	end

	if(head_byte_2)
		[out count msg]=fread(s,13,'uint8');   
		if(~isempty(msg) == 1 )
			fprintf('error:The specified amount of data was not returned within the Timeout period.');
			break;
		else
			for j=1:13
				fprintf('%02x  ',out(j,1));        
			end	
			
			[y x]=size(out);
			n=1;
			for m=1:2:(y-1)
				TwoByteData(n,1) = ( out(m,1)*256 + out(m+1,1) );
				n=n+1;
			end	

			% signed to unsigned
			[y x]=size(TwoByteData);
			for j=1:y
				for i=1:x
					if(TwoByteData(j,i) > (2^15 -1))
						TwoByteData(j,i) = TwoByteData(j,i) - (2^16);
					end
				end
			end
			
			fprintf('  '); 
			for j=1:y
			% for j=1:3
			% for j=4:y
				for i=1:x
					if int16(TwoByteData(j,i)/16) == -1799
					fprintf('           '); 
					else
					fprintf( '%7.1f    ',(TwoByteData(j,i)/16) ); 
					end
				end
			end
			
			fprintf('\n'); 
		end

	end

	
end
  
  
fclose(s);  
delete(s);  


