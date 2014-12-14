function output = is_in_im(i, j, h, w)
%IS_IN_IM Summary of this function goes here
%   Detailed explanation goes here
    output = ~(i + 1 > h || j + 1 > w || i - 1 < 1 || j - 1 < 1);
end

