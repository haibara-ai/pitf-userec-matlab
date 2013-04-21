function ret = CreateNewIndex(users)

max_user = max(users);
ret = zeros(max_user,1);
user_count = length(users);
index = 1;
for i = 1:user_count
    ret(users(i),1) = index;
    index = index + 1;
end

end