/* @refresh reload */
import { render } from 'solid-js/web';
import { QueryClient, QueryClientProvider } from '@tanstack/solid-query';
import { SolidQueryDevtools } from '@tanstack/solid-query-devtools';
import CssBaseline from '@suid/material/CssBaseline';

import App from './App';

if (import.meta.env.DEV) {
  void import('solid-devtools');
  void import('@solid-devtools/overlay').then(({ attachDevtoolsOverlay }) => {
    const cleanup = attachDevtoolsOverlay();
    if (import.meta.hot) {
      import.meta.hot.dispose(cleanup);
    }
  });
}

const root = document.getElementById('root');
const queryClient = new QueryClient();

if (import.meta.env.DEV && !(root instanceof HTMLElement)) {
  throw new Error(
    'Root element not found. Did you forget to add it to your index.html? Or maybe the id attribute got misspelled?',
  );
}

render(
  () => (
    <QueryClientProvider client={queryClient}>
      <CssBaseline />
      <App />
      {import.meta.env.DEV ? <SolidQueryDevtools buttonPosition="bottom-left" /> : null}
    </QueryClientProvider>
  ),
  root!,
);
