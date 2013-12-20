function output = round255(input,offset)
%function to offset input outside of deadzone (-offset,offset), and
%truncate to be within interval [-255,-255+offset] or [offset,255]
%EG

output = input;

if input>255-offset
    output = 255-offset;
elseif input<-255+offset
    output = -255+offset;
end

