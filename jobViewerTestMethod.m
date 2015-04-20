function jobViewerTest
%% jobViewerTest tries to display a progress bar for a collection of jobs
% that are performed on a cluster
sigma = 3;
nPoints = 1000;

nJobs = 10;
% make the cluster
cluster = parcluster('local');

for ii = 1:nJobs
    filePath = fullfile(pwd,sprintf('test_j%i',ii));
    job(ii) = createJob(cluster);
    job(ii).createTask(@JobViewerObj.generateRandomStatic,3,{sigma,nPoints,filePath});
    job(ii).submit;
end

% jobs should be setup and running

jobsRunning = ones(size(job));
jobsFinished = 0;

while any(jobsRunning)
    jobsFinishedLast = jobsFinished;
    for ii = 1:nJobs
        if jobsRunning(ii)
            jobStatus  = job(ii).State;
            if strcmp(jobStatus,'finished')
                jobsRunning(ii) = 0;
                jobsFinished = jobsFinished + 1;
                % and save the data
                jobData = job(ii).fetchOutputs;
                randomData = jobData{1};
                save(jobData{2},'randomData'); % jobData{2} is the filename we passed to the job
            end
        end
    end
    if jobsFinished ~= jobsFinishedLast
        fprintf('\n%i / %i finished',sum(jobsFinished),nJobs);
    end
    pause(0.01);
end

% cleanup the jobs
for ii = 1:nJobs
    job(ii).delete;
end

fprintf('\nDone!\n');
end

function [randomData, filePath] = jobFun(jobEngine)    
    [randomData, filePath] = jobEngine.generateRandom;
end
    