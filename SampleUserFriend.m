function ret = SampleUserFriend(seeds,user_friend)

ret = zeros(size(user_friend));

seeds_count = length(seeds);
index = 1;
for i = 1:seeds_count
    temp_user_friend = user_friend(user_friend(:,1) == seeds(i),:);
    temp_uf_count = size(temp_user_friend,1);
    ret(index:index+temp_uf_count-1,:) = temp_user_friend;
    index = index+temp_uf_count;
end
ret(ret(:,1)==0,:) = [];
end