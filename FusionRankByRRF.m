function ret = FusionRankByRRF(test_posts,userrec,predict_count)

users = unique(test_posts(:,1));
user_count = length(users);
ret = zeros(user_count*predict_count,2);
default_rank = 2*predict_count;
default_k = 50;
for i = 1:user_count
    fprintf('user %d\n',users(i));
    ret((i-1)*predict_count+1:i*predict_count,1) = users(i);
    single_userrec = userrec(userrec(:,1) == users(i),:);
    temp_ranks = unique(single_userrec(:,[1,2]),'rows');
    temp_rank_count = size(temp_ranks,1);
    temp_friends = unique(single_userrec(:,3));
    temp_friends_count = length(temp_friends);
    refine_ranks = zeros(predict_count,temp_rank_count);
    final_rank = zeros(temp_friends_count,2);
    for j = 1:temp_rank_count
        ori_rank = single_userrec(single_userrec(:,1) == temp_ranks(j,1) & single_userrec(:,2) == temp_ranks(j,2),3:4);
        ori_rank = flipud(sortrows(ori_rank,2));
        refine_ranks(:,j) = ori_rank(1:predict_count,1);
    end
    
    for j = 1:temp_friends_count
        final_rank(j,1) = temp_friends(j);
        rrf = 0;
        for k = 1:temp_rank_count
            rank_value = find(refine_ranks(:,k) == temp_friends(j));
            if isempty(rank_value)
                rank_value = default_rank;
            end                
            rrf = rrf + 1 / (default_k + rank_value);
        end        
        final_rank(j,2) = rrf;
    end
    final_rank = flipud(sortrows(final_rank,2));
    if isempty(final_rank)
        final_rank = zeros(predict_count,1);
    end
    ret((i-1)*predict_count+1:i*predict_count,2) = final_rank(1:predict_count,1);
end

end