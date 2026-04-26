import Box from '@suid/material/Box';
import Container from '@suid/material/Container';
import Paper from '@suid/material/Paper';
import Stack from '@suid/material/Stack';
import type { RouteSectionProps } from '@solidjs/router';
import { A } from '@solidjs/router';
import './styles.css';

const App = (props: Readonly<RouteSectionProps>) => {
    return (
        <Box class="app-shell">
            <Container maxWidth="md" sx={{ py: 6 }}>
                <Stack spacing={4}>
                    <Paper class="app-nav-shell" elevation={0}>
                        <nav class="app-nav">
                            <A activeClass="app-nav-link-active" class="app-nav-link" href="/products">
                                Products
                            </A>
                            <A activeClass="app-nav-link-active" class="app-nav-link" href="/stock">
                                In Stock
                            </A>
                        </nav>
                    </Paper>
                    {props.children}
                </Stack>
            </Container>
        </Box>
    );
};

export default App;
