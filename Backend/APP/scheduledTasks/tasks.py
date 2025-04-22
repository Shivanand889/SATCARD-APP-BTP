from celery import shared_task

@shared_task
def task_one():
    print("Task One: Running every 10 minutes")

@shared_task
def task_two():
    print("Task Two: Running every 30 minutes")

from celery import shared_task

@shared_task
def task_three():
    print("Running task_three...")
    return "Task completed successfully"

