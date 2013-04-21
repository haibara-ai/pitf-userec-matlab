function ret = ConvertTernaryToNewIndex(ternary,first_index,second_index,third_index)

ret = zeros(size(ternary));
for i = 1:size(ternary,1)
    ret(i,1) = first_index(ternary(i,1),1);
    ret(i,2) = second_index(ternary(i,2),1);
    ret(i,3) = third_index(ternary(i,3),1);
end 

end