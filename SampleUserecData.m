function [new_user_contact,new_user_tag_contact,new_user_tag_cell,new_user_index,new_tag_index,new_contact_index] = SampleUserecData(user_contact,user_tag_contact,user_tag_cell,sample_user_cnt)
% user and contact appeared in user_contact muse be included in user_tag
users = unique(user_contact(:,1));
user_cnt = length(users);
rand_index = randperm(user_cnt);
sample_users = users(rand_index(1:sample_user_cnt));

sample_user_contact = FiltData(user_contact,1,sample_users);
sample_contact = unique(sample_user_contact(:,2));
sample_user_tag_contact = AchieveUserTagFriendByUserFriend(user_tag_contact,sample_user_contact);
sample_user_tag_cell = user_tag_cell(sample_users,:);
sample_tag = sample_user_tag_contact(:,2);

new_user_index = CreateNewIndex(sample_users);
new_contact_index = CreateNewIndex(sample_contact);
new_tag_index = CreateNewIndex(sample_tag);

new_user_contact = ConvertPairToNewIndex(sample_user_tag,new_user_index,new_contact_index);
new_user_tag_contact = ConvertTernaryToNewIndex(sample_user_tag_contact,new_user_index,new_tag_index,new_contact_index);

% convert sample_user_tag_cell to new index
new_user_tag_cell = cell(sample_user_cnt,1);
for i = 1:sample_user_cnt
    temp_tags = sample_user_tag_cell{sample_users(i)};
    new_tags = zeros(size(temp_tags));
    for j = 1:size(temp_tags,1)
        if temp_tags(j,1) > length(new_tag_index)
            continue;
        end
        new_tags(j,1) = new_tag_index(temp_tags(j,1));
        new_tags(j,2) = temp_tags(j,2);        
    end
    new_tags(new_tags(:,1) == 0,:) = [];
    new_user_tag_cell{new_user_index(sample_users(i))} = new_tags;
end


end