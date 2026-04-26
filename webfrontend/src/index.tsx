/* @refresh reload */
import { render } from 'solid-js/web';
import { QueryClient, QueryClientProvider } from '@tanstack/solid-query';
import { SolidQueryDevtools } from '@tanstack/solid-query-devtools';
import CssBaseline from '@suid/material/CssBaseline';

import App from './App';
import { attachDevtoolsOverlay } from '@solid-devtools/overlay';

const root = document.getElementById('root');
const queryClient = new QueryClient();

if (!(root instanceof HTMLElement)) {
  throw new Error(
    'Root element not found. Did you forget to add it to your index.html? Or maybe the id attribute got misspelled?',
  );
}

render(
  () => (
    <QueryClientProvider client={queryClient}>
      <CssBaseline />
      <App />
      <SolidQueryDevtools buttonPosition="bottom-left" />
    </QueryClientProvider>
  ),
  root,
);

attachDevtoolsOverlay({ noPadding: true });
