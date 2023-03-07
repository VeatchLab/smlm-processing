function cullspec_summary(cullspec)

fprintf('Field\t\tculltype\tmin\tmax\t\n');

for i = 1:numel(cullspec),
    fprintf('%-12s\t%-10s\t%.3f\t%.3f\t\n', cullspec(i).field, cullspec(i).culltype,...
            cullspec(i).min, cullspec(i).max);
end
