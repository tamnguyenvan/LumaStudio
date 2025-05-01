from concurrent.futures import ThreadPoolExecutor
from PySide6.QtCore import QObject, Signal
from typing import Any, Callable
import traceback

class Job:
    def __init__(self, job_id: str, func: Callable, *args, **kwargs):
        self.id = job_id
        self.func = func
        self.args = args
        self.kwargs = kwargs
        self.progress = 0
        self.result = None
        self.error = None

class JobManager(QObject):
    jobStarted = Signal(str)  # job_id
    jobProgress = Signal(str, float)  # job_id, progress (0-1)
    jobCompleted = Signal(str, object)  # job_id, result
    jobFailed = Signal(str, str)  # job_id, error_message

    def __init__(self):
        super().__init__()
        self._executor = None
        self._active_jobs = {}

    def submit_job(self, job_id: str, func: Callable, *args, **kwargs) -> None:
        """Submit a job to be executed in a separate thread"""
        job = Job(job_id, func, *args, **kwargs)
        self._active_jobs[job_id] = job
        
        def _wrapped_func():
            try:
                self.jobStarted.emit(job_id)
                result = job.func(*job.args, **job.kwargs)
                job.result = result
                self.jobCompleted.emit(job_id, result)
            except Exception as e:
                error_msg = f"Error in job {job_id}: {str(e)}\n{traceback.format_exc()}"
                job.error = error_msg
                self.jobFailed.emit(job_id, error_msg)
            finally:
                if job_id in self._active_jobs:
                    del self._active_jobs[job_id]

        if self._executor is None:
            self._executor = ThreadPoolExecutor(max_workers=2)
        self._executor.submit(_wrapped_func)

    def update_progress(self, job_id: str, progress: float) -> None:
        """Update the progress of a job (0-1)"""
        if job_id in self._active_jobs:
            self._active_jobs[job_id].progress = progress
            self.jobProgress.emit(job_id, progress)

    def cancel_job(self, job_id: str) -> None:
        """Cancel a running job"""
        if job_id in self._active_jobs:
            # Note: This doesn't actually stop the thread, but marks it as cancelled
            del self._active_jobs[job_id]
            self.jobFailed.emit(job_id, "Job cancelled")
