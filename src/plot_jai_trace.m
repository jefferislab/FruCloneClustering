function x1=plot_jai_trace(trace_file)

[s1 s2 s3 s4 s5 s6 s6]=textread(trace_file,'%s %s %s %s %s %s %s');
x1=zeros(length(s1)-6,3);

for i=7:length(s1);
    if ~isempty(str2num(s3{i}))
    x1(i-6,1)=str2num(s3{i});
    x1(i-6,2)=str2num(s4{i});
    x1(i-6,3)=str2num(s5{i});
    end
    
end

plot3(x1(:,1),x1(:,2),x1(:,3),'r.');