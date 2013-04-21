function ret = ConvertPairToNewIndex(user_tag_vector,user_new_index,tag_new_index)

ret = user_tag_vector;
for i = 1:size(user_tag_vector,1)
    ret(i,1) = user_new_index(user_tag_vector(i,1),1);
    ret(i,2) = tag_new_index(user_tag_vector(i,2),1);
end    
end