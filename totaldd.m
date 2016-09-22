function dd = totaldd(input)
% get the max drawdown in a cumulative profit curve
newmax = -99999999 ; 
dds = zeros(size(input)) ; 
for i=1:length(input)
    if input(i) > newmax
        newmax = input(i) ; 
    end
    dds(i) = newmax - input(i) ; 
end

dd = max(dds) ; 
end