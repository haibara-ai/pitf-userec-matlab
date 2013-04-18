function ret = BuildFrdCases(user_tag_friend)

fprintf('build friend case...\n');
num_frd_case = size(user_tag_friend,1);
fprintf('num_frd_case:%d\n',num_frd_case);
frd_cases = cell(num_frd_case,4);
user_tag_post = unique(user_tag_friend(:,1:2),'rows');
fci = 1;
for i = 1:size(user_tag_post,1)
    if mod(i,1000) == 1
        fprintf('%d/%d\n',i,size(user_tag_post,1));
    end
    post_frds = user_tag_friend(user_tag_friend(:,1) == user_tag_post(i,1) & user_tag_friend(:,2) == user_tag_post(i,2),3);
    for j = 1:length(post_frds)
        frd_cases{fci,1} = user_tag_post(i,1);
        frd_cases{fci,2} = user_tag_post(i,2);
        frd_cases{fci,3} = post_frds(j,1);
        frd_cases{fci,4} = post_frds;        
        fci = fci + 1;
    end
end
fprintf('build friend case end...\n');
ret = frd_cases;
end