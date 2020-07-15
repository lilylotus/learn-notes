/**
* 自定线程池捕捉异常信息
*/
public class TraceTreadPoolExecutor extends ThreadPoolExecutor {
    public TraceTreadPoolExecutor(int corePoolSize, int maximumPoolSize, long keepAliveTime, TimeUnit unit, BlockingQueue<Runnable> workQueue) {
        super(corePoolSize, maximumPoolSize, keepAliveTime, unit, workQueue);
    }


    @Override
    public void execute(Runnable command) {
        super.execute(wrap(command, clientTrace(), Thread.currentThread().getName()));
    }

    @Override
    public Future<?> submit(Runnable task) {
        return super.submit(wrap(task, clientTrace(), Thread.currentThread().getName()));
    }

    private Runnable wrap(final Runnable task, final Exception clientStack, String clientThreadName) {
        return new Runnable() {
            @Override
            public void run() {
                try {
                    task.run();
                } catch (Exception e) {
                    clientStack.printStackTrace();
                    throw e;
                }
            }
        };
    }

    private Exception clientTrace() {
        return new Exception("Client stack trace.");
    }

    public static void main2(String[] args) throws ExecutionException, InterruptedException {

        ThreadPoolExecutor poolExecutor = new TraceTreadPoolExecutor(0, Integer.MAX_VALUE, 0L, TimeUnit.SECONDS, new SynchronousQueue<Runnable>());

        for (int i = 0; i < 5; i++) {
            Future<?> future = poolExecutor.submit(new DivTask(100, i));
            future.get();
//            poolExecutor.execute(new DivTask(100, i));
        }


    }    

}