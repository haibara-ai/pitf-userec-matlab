function BatchRunScript(sample445_utf_size,sample445_frd_cases_train_new,sample445_user_tag_cell_new,sample445_user_friend_train_new,sample445_user_friend_test_new)

dims = [16,32,64,128,256,512,1024];
repeat_num = 5;

parfor i = 1:length(dims)
    for j = 1:repeat_num
        Userec(sample445_utf_size,sample445_frd_cases_train_new,sample445_user_tag_cell_new,sample445_user_friend_train_new,sample445_user_friend_test_new,dims(i));
    end
end

end