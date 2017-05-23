// This test demonstrates and confirms the ability to use sv_test
// on classes, without UVM and without any modules.
// ... and the Game of LIfe is a fun little coding exercise.

// GOL = Game Of Life
// See https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life

`include "sv_test.svh"

typedef longint unsigned pos_hash_t;

// A position class.
// We don't want the "primitive obsession" code smell!
// See http://www.jamesshore.com/Blog/PrimitiveObsession.html
// See https://en.wikipedia.org/wiki/Code_smell
class pos;
    int x, y;

    function new(int x=0, int y=0);
        this.x = x;
        this.y = y;
    endfunction

    virtual function pos clone();
        clone = new(x, y);
    endfunction

    virtual function void get_neighbors(ref pos neighbors[$]);
        for (int i = x-1; i < x+2; i++) begin
            for (int j = y-1; j < y+2; j++) begin
                pos neighbor;
                if (i==x && j==y) continue;
                neighbor = new(i, j);
                neighbors.push_back(neighbor);
            end
        end
    endfunction

    virtual function pos_hash_t get_hash();
        get_hash = x;
        get_hash <<= 32;
        get_hash |= y;
    endfunction

    virtual function void set_from_hash(pos_hash_t h);
        y = h & ((1<<32)-1);
        x = h >> 32;
    endfunction
endclass


typedef enum {
    DEAD = 0,
    ALIVE = 1
} cell_state_t;


// The Class Under Test
class gol;
    cell_state_t    world[pos_hash_t];
    cell_state_t    next_world[pos_hash_t];
    bit             cells_to_iterate[pos_hash_t];

    virtual function void make_alive(pos p);
        // alive_cells.push_back(p.clone());
        world[p.get_hash()] = ALIVE;
    endfunction

    virtual function void get_alive_cells(ref pos alive_cells[$]);
        foreach (world[h]) begin
            if (world[h] == ALIVE) begin
                pos p = new();
                p.set_from_hash(h);
                alive_cells.push_back(p);
            end
        end
    endfunction

    virtual function void get_alive_neighbors(pos p, ref pos alive_neighbors[$]);
        pos neighbors[$];

        alive_neighbors.delete();

        p.get_neighbors(neighbors);
        foreach (neighbors[i]) begin
            pos_hash_t  h = neighbors[i].get_hash();

            if (world.exists(h) && world[h] == ALIVE) alive_neighbors.push_back(neighbors[i]);
        end
    endfunction

    virtual function void build_cells_to_iterate();
        cells_to_iterate.delete();
        foreach (world[h]) begin
            pos p = new();
            pos neighbors[$];

            p.set_from_hash(h);
            p.get_neighbors(neighbors);

            cells_to_iterate[h] = 1;
            foreach (neighbors[i]) cells_to_iterate[neighbors[i].get_hash()] = 1;
        end
    endfunction

    virtual function cell_state_t next_cell_state(cell_state_t current_state, int num_alive_neighbors);
        if (num_alive_neighbors == 3) return ALIVE; // Reproduction
        if (num_alive_neighbors  < 2) return DEAD; // Underpopulation
        if (num_alive_neighbors  > 3) return DEAD; // Overpopulation
        return current_state; // Status Quo
    endfunction

    virtual function void build_next_world();
        next_world.delete();
        foreach (cells_to_iterate[h]) begin
            pos          an[$], p = new();
            cell_state_t ns, cs;

            p.set_from_hash(h);
            get_alive_neighbors(p, an);
            cs = world.exists(h) ? world[h] : DEAD;
            ns = next_cell_state(cs, an.size());
            if (ns != DEAD) next_world[h] = ns;
        end
    endfunction

    virtual function void step();
        build_cells_to_iterate();
        build_next_world();
        world = next_world;
    endfunction
endclass



class gol_fixture extends sv_test_pkg::sv_test_fixture;
    gol     cut;

    // Test helpers
    pos     p;
    pos     p2;
    pos     p_q[$];

    function new(unit_test_pkg::unit_test_runner tr);
        super.new(tr);
    endfunction

    virtual task setup();
        cut = new();
    endtask

    virtual task teardown();
        p = null;
        p2 = null;
        p_q.delete();
    endtask
endclass


`SV_TEST(pos_neighbors)
    pos  p = new(3, 104);
    pos  neighbors[$];
    p.get_neighbors(neighbors);
    `ASSERT_EQ(neighbors.size(), 8)
    `ASSERT_HAS(pos, neighbors, item.x==2 && item.y==103)
    `ASSERT_HAS(pos, neighbors, item.x==2 && item.y==104)
    `ASSERT_HAS(pos, neighbors, item.x==2 && item.y==105)
    `ASSERT_HAS(pos, neighbors, item.x==3 && item.y==103)
    `ASSERT_HAS(pos, neighbors, item.x==3 && item.y==105)
    `ASSERT_HAS(pos, neighbors, item.x==4 && item.y==103)
    `ASSERT_HAS(pos, neighbors, item.x==4 && item.y==104)
    `ASSERT_HAS(pos, neighbors, item.x==4 && item.y==105)
`END_SV_TEST

`SV_TEST(pos_hash)
    pos         p = new('h8FFFFFF7, 'hA0000001);
    pos_hash_t  h = p.get_hash();
    `ASSERT_EQ(h, 64'h8FFFFFF7A0000001)
    p = new();
    p.set_from_hash(h);
    `ASSERT_TRUE(p!=null && p.x=='h8FFFFFF7 && p.y=='hA0000001)
`END_SV_TEST


`SV_TEST_F(gol_fixture, uninitialized_world_is_empty)
    cut.get_alive_cells(p_q);
    `ASSERT_EQ(p_q.size(), 0)
`END_SV_TEST

`SV_TEST_F(gol_fixture, a_cell_can_be_made_alive_and_dead)
    p = new(3, 7);
    cut.make_alive(p);
    cut.get_alive_cells(p_q);
    `ASSERT_EQ(p_q.size(), 1)
    if (p_q.size() < 1) return;
    `ASSERT_NOT_NULL(p_q[0])
    if (p_q[0] == null) return;
    `ASSERT_EQ(p_q[0].x, 3)
    `ASSERT_EQ(p_q[0].y, 7)
`END_SV_TEST

`SV_TEST_F(gol_fixture, input_to_the_make_alive_method_is_copied)
    p = new(0, 0);
    cut.make_alive(p);
    p.x = 1;
    p.y = 2;
    cut.get_alive_cells(p_q);
    `ASSERT_HAS(pos, p_q, item.x==0 && item.y==0)
`END_SV_TEST

`SV_TEST_F(gol_fixture, getting_alive_neighbors)
    p2 = new(0, 0);
    cut.get_alive_neighbors(p2, p_q);
    `ASSERT_EQ(p_q.size(), 0);

    p = new(-1, 1);
    cut.make_alive(p);
    cut.get_alive_neighbors(p2, p_q);
    `ASSERT_EQ(p_q.size(), 1)
    `ASSERT_HAS(pos, p_q, item.x==-1 && item.y==1)

    p = new(0, 1);
    cut.make_alive(p);
    cut.get_alive_neighbors(p2, p_q);
    `ASSERT_EQ(p_q.size(), 2)
    `ASSERT_HAS(pos, p_q, item.x==-1 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==0 && item.y==1)

    p = new(1, 1);
    cut.make_alive(p);
    cut.get_alive_neighbors(p2, p_q);
    `ASSERT_EQ(p_q.size(), 3)
    `ASSERT_HAS(pos, p_q, item.x==-1 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==0 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==1 && item.y==1)

    p = new(-1, 0);
    cut.make_alive(p);
    cut.get_alive_neighbors(p2, p_q);
    `ASSERT_EQ(p_q.size(), 4)
    `ASSERT_HAS(pos, p_q, item.x==-1 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==0 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==1 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==-1 && item.y==0)

    p = new(1, 0);
    cut.make_alive(p);
    cut.get_alive_neighbors(p2, p_q);
    `ASSERT_EQ(p_q.size(), 5)
    `ASSERT_HAS(pos, p_q, item.x==-1 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==0 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==1 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==-1 && item.y==0)
    `ASSERT_HAS(pos, p_q, item.x==1 && item.y==0)

    p = new(-1, -1);
    cut.make_alive(p);
    cut.get_alive_neighbors(p2, p_q);
    `ASSERT_EQ(p_q.size(), 6)
    `ASSERT_HAS(pos, p_q, item.x==-1 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==0 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==1 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==-1 && item.y==0)
    `ASSERT_HAS(pos, p_q, item.x==1 && item.y==0)
    `ASSERT_HAS(pos, p_q, item.x==-1 && item.y==-1)

    p = new(0, -1);
    cut.make_alive(p);
    cut.get_alive_neighbors(p2, p_q);
    `ASSERT_EQ(p_q.size(), 7)
    `ASSERT_HAS(pos, p_q, item.x==-1 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==0 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==1 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==-1 && item.y==0)
    `ASSERT_HAS(pos, p_q, item.x==1 && item.y==0)
    `ASSERT_HAS(pos, p_q, item.x==-1 && item.y==-1)
    `ASSERT_HAS(pos, p_q, item.x==0 && item.y==-1)

    p = new(1, -1);
    cut.make_alive(p);
    cut.get_alive_neighbors(p2, p_q);
    `ASSERT_EQ(p_q.size(), 8)
    `ASSERT_HAS(pos, p_q, item.x==-1 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==0 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==1 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==-1 && item.y==0)
    `ASSERT_HAS(pos, p_q, item.x==1 && item.y==0)
    `ASSERT_HAS(pos, p_q, item.x==-1 && item.y==-1)
    `ASSERT_HAS(pos, p_q, item.x==0 && item.y==-1)
    `ASSERT_HAS(pos, p_q, item.x==1 && item.y==-1)

    p = new(0, 0);
    cut.make_alive(p);
    cut.get_alive_neighbors(p2, p_q);
    `ASSERT_EQ(p_q.size(), 8)

    p = new(2, 2);
    cut.make_alive(p);
    cut.get_alive_neighbors(p2, p_q);
    `ASSERT_EQ(p_q.size(), 8)
`END_SV_TEST

`SV_TEST_F(gol_fixture, alive_cell_with_two_neighbors_lives_on_by_status_quo)
    p = new(0, 1); cut.make_alive(p);
    p = new(0, 2); cut.make_alive(p);
    p = new(0, 3); cut.make_alive(p);

    cut.step();

    cut.get_alive_cells(p_q);
    `ASSERT_HAS(pos, p_q, item.x==0 && item.y==2)
`END_SV_TEST

`SV_TEST_F(gol_fixture, dead_cell_with_two_neighbors_remains_dead_by_status_quo)
    p = new(0, 1); cut.make_alive(p);
    p = new(0, 3); cut.make_alive(p);

    cut.step();

    cut.get_alive_cells(p_q);
    `ASSERT_DOES_NOT_HAVE(pos, p_q, item.x==0 && item.y==2)
`END_SV_TEST

`SV_TEST_F(gol_fixture, dead_cell_with_three_neighbors_becomes_alive_as_if_by_reproduction)
    // This is actually the "blinker" oscillator pattern
    p = new(0, 0); cut.make_alive(p);
    p = new(1, 0); cut.make_alive(p);
    p = new(2, 0); cut.make_alive(p);

    cut.step();

    cut.get_alive_cells(p_q);
    `ASSERT_HAS(pos, p_q, item.x==1 && item.y==1)
    `ASSERT_HAS(pos, p_q, item.x==1 && item.y==0)
    `ASSERT_HAS(pos, p_q, item.x==1 && item.y==-1)

    cut.step();

    cut.get_alive_cells(p_q);
    `ASSERT_HAS(pos, p_q, item.x==0 && item.y==0)
    `ASSERT_HAS(pos, p_q, item.x==1 && item.y==0)
    `ASSERT_HAS(pos, p_q, item.x==2 && item.y==0)
`END_SV_TEST

`SV_TEST_F(gol_fixture, alive_cell_with_zero_neighbors_dies_as_if_by_underpopulation)
    p = new(0, 0); cut.make_alive(p);

    cut.step();

    cut.get_alive_cells(p_q);
    `ASSERT_EQ(p_q.size(), 0)
`END_SV_TEST

`SV_TEST_F(gol_fixture, alive_cell_with_one_neighbor_dies_as_if_by_underpopulation)
    p = new(0, 0); cut.make_alive(p);
    p = new(1, 0); cut.make_alive(p);

    cut.step();

    cut.get_alive_cells(p_q);
    `ASSERT_EQ(p_q.size(), 0)
`END_SV_TEST

`SV_TEST_F(gol_fixture, alive_cell_with_four_neighbors_dies_as_if_by_overpopulation)
    p = new(1, 1); cut.make_alive(p);

    p = new(0, 0); cut.make_alive(p);
    p = new(2, 0); cut.make_alive(p);
    p = new(0, 2); cut.make_alive(p);
    p = new(2, 2); cut.make_alive(p);

    cut.step();

    cut.get_alive_cells(p_q);
    `ASSERT_DOES_NOT_HAVE(pos, p_q, item.x==1 && item.y==1)
`END_SV_TEST

`SV_TEST_F(gol_fixture, alive_cell_with_eight_neighbors_dies_as_if_by_overpopulation)
    p = new(1, 1); cut.make_alive(p);

    p = new(0, 0); cut.make_alive(p);
    p = new(1, 0); cut.make_alive(p);
    p = new(2, 0); cut.make_alive(p);
    p = new(0, 1); cut.make_alive(p);
    p = new(2, 1); cut.make_alive(p);
    p = new(0, 2); cut.make_alive(p);
    p = new(1, 2); cut.make_alive(p);
    p = new(2, 2); cut.make_alive(p);

    cut.step();

    cut.get_alive_cells(p_q);
    `ASSERT_DOES_NOT_HAVE(pos, p_q, item.x==1 && item.y==1)
`END_SV_TEST

